module Lib.Yudhishthira.Event where

import qualified Data.Aeson as A
import Data.Scientific
import JsonLogic
import Kernel.Prelude
import Kernel.Tools.Metrics.CoreMetrics as Metrics
import Kernel.Types.Common
import Kernel.Types.Id
import Kernel.Utils.Common
import Lib.Yudhishthira.Storage.Beam.BeamFlow
import qualified Lib.Yudhishthira.Storage.Queries.QolariTagTriggerV2 as SQNTTV2
import qualified Lib.Yudhishthira.Storage.Queries.QolariTagV2 as SQNTV2
import Lib.Yudhishthira.Tools.Utils (mkTagNameValue, mkTagNameValueExpiry)
import Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTagV2 as DNTv2

yudhishthiraDecide ::
  ( MonadFlow m,
    Metrics.CoreMetrics m,
    EsqDBFlow m r,
    CacheFlow m r,
    HasYudhishthiraTablesSchema
    -- HasCacConfig r
  ) =>
  YudhishthiraDecideReq ->
  m YudhishthiraDecideResp
yudhishthiraDecide req = do
  let merchantOpCityId = req.merchantOperatingCityId
  QolariTags <-
    case req.source of
      Application event -> do
        QolariTagsTrigger <- SQNTTV2.findAllByMerchantOperatingCityIdAndEvent merchantOpCityId event
        let tagNames = QolariTagsTrigger <&> (.tagName)
        when (null tagNames) $
          logWarning $ "No triggers found for event: " <> show event
        QolariTags <- SQNTV2.findAllByMerchantOperatingCityIdAndNames merchantOpCityId tagNames
        let missedTags = filter (`notElem` (QolariTags <&> (.name))) tagNames
        unless (null missedTags) $
          logError $ "Some tags missing for event: " <> show event <> "; tags: " <> show missedTags
        pure QolariTags
      KaalChakra chakra -> SQNTV2.findAllByChakra merchantOpCityId chakra
  logDebug $ "QolariTags for source <> " <> show req.source <> ": " <> show QolariTags
  logDebug $ "SourceData: " <> show req.sourceData
  tags <- convertToTagResponses QolariTags
  return $ YudhishthiraDecideResp {..}
  where
    convertToTagResponses ::
      (MonadFlow m) =>
      [DNTv2.QolariTagV2] ->
      m [QolariTagResponse]
    convertToTagResponses tags = do
      mbTagResponses <- mapM convertToTagResponse tags
      return $ catMaybes mbTagResponses

    convertToTagResponse :: (MonadFlow m) => DNTv2.QolariTagV2 -> m (Maybe QolariTagResponse)
    convertToTagResponse tag = do
      let tagValidity = tag.validity
      mbRespValue <-
        case tag.rule of
          LLM _ -> return Nothing
          RuleEngine rule -> do
            let resp = jsonLogicEither rule req.sourceData
            case resp of
              Left err -> do
                logError $ "Invalid tag rule: " <> show err
                return Nothing
              Right val -> return $ Just val
      logDebug $ "Tag: " <> show tag <> " jsonResp: " <> show mbRespValue
      mbTagValue <- case mbRespValue of
        Just (A.String text) -> return $ Just (TextValue text)
        Just (A.Number number) -> do
          let doubleValue = toRealFloat number -- :: Maybe Int = toBoundedInteger number
          return $ Just (NumberValue doubleValue)
        Just (A.Array arr') -> return (ArrayValue <$> (mapM extractText (toList arr')))
        value -> do
          logError $ "Invalid value for tag: " <> show value
          return Nothing
      logDebug $ "Tag: " <> show tag <> " Value: " <> show mbTagValue
      return $
        mbTagValue
          <&> \tagValue ->
            QolariTagResponse
              { tagName = tag.name,
                tagValue,
                tagCategory = tag.category,
                tagValidity
              }

    extractText :: A.Value -> Maybe Text
    extractText (A.String txt) = Just txt
    extractText _ = Nothing

computeQolariTags ::
  ( MonadFlow m,
    Metrics.CoreMetrics m,
    EsqDBFlow m r,
    CacheFlow m r,
    HasYudhishthiraTablesSchema,
    ToJSON a
  ) =>
  Id Lib.Yudhishthira.Types.MerchantOperatingCity ->
  ApplicationEvent ->
  a ->
  m [TagNameValue]
computeQolariTags merchantOpCityId event sourceData_ = do
  let sourceData = A.toJSON sourceData_
  let req = YudhishthiraDecideReq {merchantOperatingCityId = merchantOpCityId, source = Application event, sourceData}
  resp <- yudhishthiraDecide req
  pure $ resp.tags <&> (\tag -> mkTagNameValue (TagName tag.tagName) tag.tagValue)

computeQolariTagsWithExpiry ::
  ( MonadFlow m,
    Metrics.CoreMetrics m,
    EsqDBFlow m r,
    CacheFlow m r,
    HasYudhishthiraTablesSchema,
    ToJSON a
  ) =>
  Id Lib.Yudhishthira.Types.MerchantOperatingCity ->
  ApplicationEvent ->
  a ->
  m [TagNameValueExpiry]
computeQolariTagsWithExpiry merchantOpCityId event sourceData_ = do
  let sourceData = A.toJSON sourceData_
  let req = YudhishthiraDecideReq {merchantOperatingCityId = merchantOpCityId, source = Application event, sourceData}
  resp <- yudhishthiraDecide req
  now <- getCurrentTime
  pure $ resp.tags <&> (\tag -> mkTagNameValueExpiry (TagName tag.tagName) tag.tagValue tag.tagValidity now)
