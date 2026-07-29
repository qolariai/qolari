{-# OPTIONS_GHC -Wno-orphans #-}

module Handler where

import API
import App.Types
import Data.Aeson (decode, eitherDecode, encode)
import qualified Data.ByteString.Lazy as LBS
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Time (UTCTime)
import qualified Data.Time as Time
import Data.UUID.V4 as UUIDV4
import EulerHS.Prelude hiding (id)
import Kernel.Beam.Lib.UtilsTH (HasSchemaName (..))
import qualified Kernel.External.Payment.Interface.Types as Payment
import qualified Kernel.External.Payment.Gateway.Types as Qolari
import qualified Kernel.Storage.Beam.SystemConfigs as BeamSC
import Kernel.Types.Beckn.Ack (AckResponse (..))
import Kernel.Types.Common
import Kernel.Types.Error (GenericError (InternalError))
import Kernel.Types.Id
import Kernel.Utils.Common (throwError)
import Kernel.Utils.Error.FlowHandling (withFlowHandlerAPI')
import Kernel.Utils.Logging (logInfo)
import qualified Lib.Payment.Domain.Action as PaymentAction
import qualified Lib.Payment.Domain.Types.PaymentOrder as DOrder
import qualified Lib.Payment.Domain.Types.PaymentOrderOffer as DOffer
import qualified Lib.Payment.Domain.Types.PaymentTransaction as DTxn
import qualified Lib.Payment.Domain.Types.Refunds as DRefunds
import Lib.Payment.Storage.Beam.BeamFlow ()
import qualified Lib.Payment.Storage.Beam.Offer as BeamOffer
import qualified Lib.Payment.Storage.Beam.OfferStats as BeamOfferStats
import qualified Lib.Payment.Storage.Beam.OfflineOffer as BeamOfflineOffer
import qualified Lib.Payment.Storage.Beam.PaymentOrder as BeamPO
import qualified Lib.Payment.Storage.Beam.PaymentOrderOffer as BeamOffer
import qualified Lib.Payment.Storage.Beam.PaymentOrderSplit as BeamPOS
import qualified Lib.Payment.Storage.Beam.PaymentTransaction as BeamPT
import qualified Lib.Payment.Storage.Beam.PayoutOrder as BeamPOO
import qualified Lib.Payment.Storage.Beam.PayoutRequest as BeamPR
import qualified Lib.Payment.Storage.Beam.PayoutTransaction as BeamPOT
import qualified Lib.Payment.Storage.Beam.PersonDailyOfferStats as BeamPersonDailyOfferStats
import qualified Lib.Payment.Storage.Beam.PersonWallet as BeamPW
import qualified Lib.Payment.Storage.Beam.Refunds as BeamRF
import qualified Lib.Payment.Storage.Beam.Wallet as BeamWallet
import qualified Lib.Payment.Storage.Beam.WalletHistory as BeamWH
import qualified Lib.Payment.Storage.Beam.WalletPayments as BeamWP
import qualified Lib.Payment.Storage.Beam.WalletRewardPosting as BeamWRP
import qualified Lib.Payment.Storage.HistoryQueries.PaymentTransaction as HQTxn
import qualified Lib.Payment.Storage.HistoryQueries.Refunds as HQRefunds
import qualified Lib.Payment.Storage.Queries.PaymentOrder as QOrder
import qualified Lib.Payment.Storage.Queries.PaymentOrderOffer as QOffer
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Client.TLS as TLS
import Network.HTTP.Types.Status (statusCode)
import Servant ((:<|>) (..))
import Servant.Client (showBaseUrl)
import Servant.Server (ServerError (..), err400, err500)

instance HasSchemaName BeamSC.SystemConfigsT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPO.PaymentOrderT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamOffer.PaymentOrderOfferT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPOS.PaymentOrderSplitT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPT.PaymentTransactionT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamRF.RefundsT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPOO.PayoutOrderT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPR.PayoutRequestT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPOT.PayoutTransactionT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamWRP.WalletRewardPostingT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPW.PersonWalletT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamWallet.WalletT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamWP.WalletPaymentsT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamWH.WalletHistoryT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamOffer.OfferT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamPersonDailyOfferStats.PersonDailyOfferStatsT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamOfferStats.OfferStatsT where
  schemaName _ = "atlas_app"

instance HasSchemaName BeamOfflineOffer.OfflineOfferT where
  schemaName _ = "atlas_app"

server :: FlowServer API
server = externalPaymentHandler :<|> internalOrderStatusHandler

externalPaymentHandler ::
  Text ->
  Maybe Text ->
  Maybe Text ->
  PaymentAction.PaymentStatusResp ->
  FlowHandler Value
externalPaymentHandler merchantShortId mCity mServiceType paymentStatusResp =
  withFlowHandlerAPI' $
    case paymentStatusResp of
      PaymentAction.PaymentStatus {..} -> do
        logInfo $
          "Mock Payment: Processing payment for orderId: "
            <> getId orderId

        now <- liftIO Time.getCurrentTime
        eventId <-
          liftIO $
            ("evt_" <>)
              . T.pack
              . show
              <$> UUIDV4.nextRandom

        AppEnv {QolariWebhookBaseUrl = envQolariUrl} <- ask
        let QolariBaseUrl = showBaseUrl envQolariUrl
            baseWebhookUrl =
              QolariBaseUrl
                <> "/"
                <> T.unpack merchantShortId
                <> "/service/Qolari/payment"

            cityParam =
              maybe "" (\c -> "?city=" <> T.unpack c) mCity

            serviceTypeParam =
              maybe
                ""
                (\st -> (if null cityParam then "?" else "&") <> "serviceType=%22" <> T.unpack st <> "%22")
                mServiceType

            webhookUrl = baseWebhookUrl <> cityParam <> serviceTypeParam

        mOrder <- QOrder.findByShortId orderShortId
        (mTxn, dateCreated) <- case mOrder of
          Just order -> do
            txn <- HQTxn.findNewTransactionByOrderId order.id
            pure (txn, Just order.createdAt)
          Nothing -> pure (Nothing, Nothing)

        let paymentMethod = mTxn >>= DTxn.paymentMethod
            paymentGatewayResponse = mTxn >>= DTxn.QolariResponse >>= parsePaymentGatewayResponse
            respMessage = mTxn >>= DTxn.respMessage
            respCode = mTxn >>= DTxn.respCode
            gatewayReferenceId = mTxn >>= DTxn.gatewayReferenceId
            splitSettlementResponse = mTxn >>= DTxn.splitSettlementResponse
            amountRefunded = Just $ sum $ map (.amount) $ filter (\r -> r.status == Payment.REFUND_SUCCESS) refunds

            webhookPayload =
              buildQolariWebhookPayload
                orderShortId
                status
                bankErrorMessage
                bankErrorCode
                (map toQolariRefundsData refunds)
                payerVpa
                (fmap toQolariCardInfo card)
                paymentMethodType
                txnUUID
                txnId
                effectAmount
                (fmap (map toQolariOffer) offers)
                amount
                now
                eventId
                paymentMethod
                paymentGatewayResponse
                respMessage
                respCode
                gatewayReferenceId
                dateCreated
                amountRefunded
                splitSettlementResponse

        logInfo $ "Mock Payment: Webhook Payload: " <> T.pack (show webhookPayload)

        logInfo $
          "Mock Payment: Calling Qolari Sandbox Webhook: "
            <> T.pack webhookUrl

        manager <- liftIO TLS.newTlsManager
        initialRequest <- liftIO $ HTTP.parseRequest webhookUrl

        let request =
              initialRequest
                { HTTP.method = "POST",
                  HTTP.requestBody =
                    HTTP.RequestBodyLBS $ encode webhookPayload,
                  HTTP.requestHeaders =
                    [ ("Content-Type", "application/json"),
                      ("Authorization", "Basic Y3VtdGE6Y3VtdGFAMTIz")
                    ]
                }

        response <- liftIO $ HTTP.httpLbs request manager

        let responseBody = HTTP.responseBody response
            respStatusCode =
              statusCode $ HTTP.responseStatus response

        logInfo $
          "Mock Payment: Qolari response status: "
            <> T.pack (show respStatusCode)

        logInfo $
          "Mock Payment: Qolari response body: "
            <> TE.decodeUtf8 (LBS.toStrict responseBody)

        if respStatusCode >= 200 && respStatusCode < 300
          then case eitherDecode responseBody of
            Right jsonResp -> pure jsonResp
            Left _ -> pure $ toJSON Ack
          else do
            -- Return the actual webhook error response to the caller
            let baseErr = if respStatusCode >= 400 && respStatusCode < 500 then err400 else err500
            throwM $
              baseErr
                { errHTTPCode = respStatusCode,
                  errBody = responseBody,
                  errHeaders = [("Content-Type", "application/json")]
                }
      _ ->
        throwError $
          InternalError "Expected PaymentStatus constructor"

buildQolariWebhookPayload ::
  ShortId a ->
  Payment.TransactionStatus ->
  Maybe Text ->
  Maybe Text ->
  [Qolari.RefundsData] ->
  Maybe Text ->
  Maybe Qolari.CardInfo ->
  Maybe Text ->
  Maybe Text ->
  Maybe Text ->
  Maybe HighPrecMoney ->
  Maybe [Qolari.Offer] ->
  HighPrecMoney ->
  UTCTime ->
  Text ->
  Maybe Text ->
  Maybe Qolari.PaymentGatewayResponse ->
  Maybe Text ->
  Maybe Text ->
  Maybe Text ->
  Maybe UTCTime ->
  Maybe HighPrecMoney ->
  Maybe Payment.SplitSettlementResponse ->
  Qolari.WebhookReq
buildQolariWebhookPayload
  orderShortId
  transactionStatus
  bankErrorMessage
  bankErrorCode
  refunds
  payerVpa
  card
  paymentMethodType
  txnUUID
  txnId
  effectAmount
  offers
  transactionAmount
  now
  eventId
  paymentMethod
  paymentGatewayResponse
  respMessage
  respCode
  gatewayReferenceId
  dateCreated
  amountRefunded
  splitSettlementResponse =
    Qolari.WebhookReq
      { id = eventId,
        date_created = now,
        event_name = statusToPaymentStatus transactionStatus,
        content =
          Qolari.OrderAndNotificationStatusContent
            { order =
                Just
                  Qolari.OrderData
                    { order_id = getShortId orderShortId,
                      txn_uuid = txnUUID,
                      txn_id = txnId,
                      status_id = Just $ statusToId transactionStatus,
                      event_name =
                        Just $
                          statusToPaymentStatus transactionStatus,
                      status = transactionStatus,
                      payment_method_type = paymentMethodType,
                      payment_method = paymentMethod,
                      payment_gateway_response = paymentGatewayResponse,
                      resp_message = respMessage,
                      resp_code = respCode,
                      gateway_reference_id = gatewayReferenceId,
                      amount =
                        realToFrac $
                          getHighPrecMoney transactionAmount,
                      currency = INR,
                      date_created = dateCreated,
                      mandate = Nothing,
                      payer_vpa = payerVpa,
                      bank_error_code = bankErrorCode,
                      bank_error_message = bankErrorMessage,
                      upi = Nothing,
                      card = card,
                      metadata = Nothing,
                      additional_info = Nothing,
                      links = Nothing,
                      amount_refunded = fmap (realToFrac . getHighPrecMoney) amountRefunded,
                      refunds = Just refunds,
                      split_settlement_response = splitSettlementResponse >>= toQolariSplitSettlementResponse,
                      effective_amount =
                        fmap
                          (realToFrac . getHighPrecMoney)
                          effectAmount,
                      offers = offers,
                      txn_detail = Nothing,
                      loyalty_info = Nothing,
                      txn_list = Nothing
                    },
              mandate = Nothing,
              notification = Nothing,
              txn = Nothing
            }
      }

internalOrderStatusHandler ::
  Text ->
  FlowHandler Qolari.OrderData
internalOrderStatusHandler orderShortId =
  withFlowHandlerAPI' $ do
    mOrder <- QOrder.findByShortId (ShortId orderShortId)
    case mOrder of
      Just order -> do
        let DOrder.PaymentOrder {id = orderId, shortId = orderShortId'} = order
        mTxn <- HQTxn.findNewTransactionByOrderId orderId
        refunds <- HQRefunds.findAllByOrderId orderShortId'
        offers <- QOffer.findByPaymentOrder orderId
        buildQolariOrderData order mTxn refunds offers
      Nothing ->
        throwError $ InternalError ("Order not found: " <> orderShortId)

buildQolariOrderData ::
  (MonadFlow m) =>
  DOrder.PaymentOrder ->
  Maybe DTxn.PaymentTransaction ->
  [DRefunds.Refunds] ->
  [DOffer.PaymentOrderOffer] ->
  m Qolari.OrderData
buildQolariOrderData order mTxn refunds offers = do
  let txnId = mTxn >>= DTxn.txnId
      txnUUID = mTxn >>= DTxn.txnUUID
      respMessage = mTxn >>= DTxn.respMessage
      respCode = mTxn >>= DTxn.respCode
      gatewayRefId = mTxn >>= DTxn.gatewayReferenceId
      DOrder.PaymentOrder
        { status = orderStatus,
          shortId = orderShortIdVal,
          amount = orderAmount,
          createdAt = orderCreatedAt,
          bankErrorMessage = orderBankErrorMessage,
          bankErrorCode = orderBankErrorCode,
          effectAmount = orderEffectAmount
        } = order

  pure $
    Qolari.OrderData
      { order_id =
          getShortId orderShortIdVal,
        txn_uuid = txnUUID,
        txn_id = txnId,
        status_id =
          Just $ statusToId orderStatus,
        event_name =
          Just $
            statusToPaymentStatus orderStatus,
        status =
          orderStatus,
        payment_method_type =
          mTxn >>= DTxn.paymentMethodType,
        payment_method = mTxn >>= DTxn.paymentMethod,
        payment_gateway_response = mTxn >>= DTxn.QolariResponse >>= (decode . LBS.fromStrict . TE.encodeUtf8),
        resp_message = respMessage,
        resp_code = respCode,
        gateway_reference_id = gatewayRefId,
        amount =
          realToFrac $ getHighPrecMoney orderAmount,
        currency = INR,
        date_created =
          Just orderCreatedAt,
        mandate = Nothing,
        payer_vpa = mTxn >>= DTxn.paymentMethod,
        bank_error_code =
          orderBankErrorCode,
        bank_error_message =
          orderBankErrorMessage,
        upi = Nothing,
        card = Nothing,
        metadata = Nothing,
        additional_info = Nothing,
        links = Nothing,
        amount_refunded = Just $ realToFrac $ getHighPrecMoney totalRefundedAmount,
        refunds = Just $ map domainRefundToQolari refunds,
        split_settlement_response = mTxn >>= DTxn.splitSettlementResponse >>= toQolariSplitSettlementResponse,
        effective_amount =
          fmap (realToFrac . getHighPrecMoney) orderEffectAmount,
        offers = Just $ map domainOfferToQolari offers,
        txn_detail = Nothing,
        loyalty_info = Nothing,
        txn_list = Nothing
      }
  where
    totalRefundedAmount =
      foldr
        ( \refund acc ->
            if refund.status == Payment.REFUND_SUCCESS
              then acc + refund.refundAmount
              else acc
        )
        0
        refunds

    domainOfferToQolari :: DOffer.PaymentOrderOffer -> Qolari.Offer
    domainOfferToQolari offer =
      Qolari.Offer
        { offer_id = Just offer.offer_id,
          offer_code = Just offer.offer_code,
          status = offer.status
        }

    domainRefundToQolari :: DRefunds.Refunds -> Qolari.RefundsData
    domainRefundToQolari refund =
      Qolari.RefundsData
        { id = refund.idAssignedByServiceProvider,
          amount = realToFrac refund.refundAmount,
          status = toQolariRefundStatus refund.status,
          error_message = refund.errorMessage,
          error_code = refund.errorCode,
          initiated_by = refund.initiatedBy,
          unique_request_id = getShortId refund.shortId,
          arn = refund.arn
        }

statusToPaymentStatus :: Payment.TransactionStatus -> Qolari.PaymentStatus
statusToPaymentStatus = \case
  Payment.CHARGED -> Qolari.ORDER_SUCCEEDED
  Payment.AUTO_REFUNDED -> Qolari.ORDER_REFUNDED
  _ -> Qolari.ORDER_FAILED

statusToEventName :: Payment.TransactionStatus -> Payment.PaymentStatus
statusToEventName = \case
  Payment.CHARGED -> Payment.ORDER_SUCCEEDED
  Payment.AUTO_REFUNDED -> Payment.ORDER_REFUNDED
  _ -> Payment.ORDER_FAILED

statusToId :: Payment.TransactionStatus -> Int
statusToId = \case
  Payment.NEW -> 10
  Payment.PENDING_VBV -> 20
  Payment.CHARGED -> 21
  Payment.AUTHENTICATION_FAILED -> 22
  Payment.AUTHORIZATION_FAILED -> 23
  Payment.Qolari_DECLINED -> 24
  Payment.AUTHORIZING -> 25
  Payment.COD_INITIATED -> 26
  Payment.STARTED -> 27
  Payment.AUTO_REFUNDED -> 28
  Payment.CLIENT_AUTH_TOKEN_EXPIRED -> 29
  Payment.CANCELLED -> 30
  Payment.PARTIAL_CHARGED -> 31

toQolariRefundStatus :: Payment.RefundStatus -> Qolari.RefundStatus
toQolariRefundStatus = \case
  Payment.REFUND_PENDING -> Qolari.REFUND_PENDING
  Payment.REFUND_FAILURE -> Qolari.REFUND_FAILURE
  Payment.REFUND_SUCCESS -> Qolari.REFUND_SUCCESS
  Payment.MANUAL_REVIEW -> Qolari.MANUAL_REVIEW
  Payment.REFUND_CANCELED -> Qolari.REFUND_FAILURE
  Payment.REFUND_REQUIRES_ACTION -> Qolari.REFUND_PENDING

toQolariRefundsData :: Payment.RefundsData -> Qolari.RefundsData
toQolariRefundsData Payment.RefundsData {..} =
  Qolari.RefundsData
    { id = idAssignedByServiceProvider,
      amount = realToFrac amount,
      status = toQolariRefundStatus status,
      error_message = errorMessage,
      error_code = errorCode,
      initiated_by = initiatedBy,
      unique_request_id = requestId,
      arn = arn
    }

toQolariCardInfo :: Payment.CardInfo -> Qolari.CardInfo
toQolariCardInfo Payment.CardInfo {..} =
  Qolari.CardInfo
    { card_type = cardType,
      last_four_digits = lastFourDigits,
      name_on_card = nameOnCard,
      card_brand = cardBrand,
      card_isin = cardIsin,
      card_issuer = cardIssuer
    }

toQolariOffer :: Payment.Offer -> Qolari.Offer
toQolariOffer Payment.Offer {..} =
  Qolari.Offer
    { offer_id = offerId,
      offer_code = offerCode,
      status = status
    }

parsePaymentGatewayResponse :: Text -> Maybe Qolari.PaymentGatewayResponse
parsePaymentGatewayResponse val = decode (LBS.fromStrict $ TE.encodeUtf8 val)

toQolariSplitSettlementResponse :: Payment.SplitSettlementResponse -> Maybe Qolari.SplitSettlementResponse
toQolariSplitSettlementResponse resp =
  Just $
    Qolari.SplitSettlementResponse
      { split_details = fmap (map toQolariSplitDetailsResponse) resp.splitDetails,
        split_applied = resp.splitApplied
      }

toQolariSplitDetailsResponse :: Payment.SplitDetailsResponse -> Qolari.SplitDetailsResponse
toQolariSplitDetailsResponse detail =
  Qolari.SplitDetailsResponse
    { sub_vendor_id = detail.subVendorId,
      amount = detail.amount,
      merchant_commission = detail.merchantCommission,
      gateway_sub_account_id = detail.gatewaySubAccountId,
      epg_txn_id = detail.epgTxnId,
      unique_split_id = detail.uniqueSplitId
    }
