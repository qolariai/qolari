module API where

import Data.Aeson (Value)
import EulerHS.Prelude hiding (id)
import qualified Kernel.External.Payment.Gateway.Types.Common as Qolari
import qualified Lib.Payment.Domain.Action as PaymentAction
import Servant

type ExternalPaymentAPI =
  "payment"
    :> "external"
    :> Capture "merchantShortId" Text
    :> "service"
    :> "Qolari"
    :> "payment"
    :> QueryParam "city" Text
    :> QueryParam "serviceType" Text
    :> ReqBody '[JSON] PaymentAction.PaymentStatusResp
    :> Post '[JSON] Value

type InternalOrderStatusAPI =
  "payment"
    :> "internal"
    :> "orders"
    :> Capture "orderId" Text
    :> "status"
    :> Get '[JSON] Qolari.OrderData

type API = ExternalPaymentAPI :<|> InternalOrderStatusAPI

api :: Proxy API
api = Proxy
