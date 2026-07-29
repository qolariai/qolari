{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module API.Action.Dashboard.Management.QolariTag
  ( API.Types.RiderPlatform.Management.QolariTag.API,
    handler,
  )
where

import qualified API.Types.RiderPlatform.Management.QolariTag
import qualified Dashboard.Common
import qualified Domain.Action.Dashboard.QolariTag
import qualified Domain.Types.Merchant
import qualified Environment
import EulerHS.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.APISuccess
import qualified Kernel.Types.Beckn.Context
import qualified Kernel.Types.Id
import Kernel.Utils.Common
import qualified Lib.Yudhishthira.Types
import Servant
import Tools.Auth

handler :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowServer API.Types.RiderPlatform.Management.QolariTag.API)
handler merchantId city = postQolariTagTagCreate merchantId city :<|> postQolariTagTagUpdate merchantId city :<|> postQolariTagTagVerify merchantId city :<|> deleteQolariTagTagDelete merchantId city :<|> getQolariTagTagAll merchantId city :<|> getQolariTagTagDetails merchantId city :<|> postQolariTagQueryCreate merchantId city :<|> postQolariTagQueryUpdate merchantId city :<|> deleteQolariTagQueryDelete merchantId city :<|> getQolariTagQueryDetails merchantId city :<|> postQolariTagAppDynamicLogicVerify merchantId city :<|> getQolariTagAppDynamicLogic merchantId city :<|> postQolariTagRunJob merchantId city :<|> getQolariTagTimeBounds merchantId city :<|> postQolariTagTimeBoundsCreate merchantId city :<|> deleteQolariTagTimeBoundsDelete merchantId city :<|> getQolariTagAppDynamicLogicGetLogicRollout merchantId city :<|> postQolariTagAppDynamicLogicUpsertLogicRollout merchantId city :<|> getQolariTagAppDynamicLogicVersions merchantId city :<|> getQolariTagAppDynamicLogicDomains merchantId city :<|> getQolariTagAppDynamicLogicDomainsAndEvents merchantId city :<|> getQolariTagAppDynamicLogicGetDomainSchema merchantId city :<|> getQolariTagQueryAll merchantId city :<|> postQolariTagUpdateCustomerTag merchantId city :<|> postQolariTagConfigPilotGetVersion merchantId city :<|> postQolariTagConfigPilotGetConfig merchantId city :<|> postQolariTagConfigPilotCreateUiConfig merchantId city :<|> getQolariTagConfigPilotAllConfigs merchantId city :<|> getQolariTagConfigPilotConfigDetails merchantId city :<|> getQolariTagConfigPilotGetTableData merchantId city :<|> getQolariTagConfigPilotAllUiConfigs merchantId city :<|> getQolariTagConfigPilotUiConfigDetails merchantId city :<|> getQolariTagConfigPilotGetUiTableData merchantId city :<|> getQolariTagConfigPilotAlwaysOnList merchantId city :<|> postQolariTagConfigPilotActionChange merchantId city :<|> postQolariTagConfigPilotGetConfigWithDimensions merchantId city :<|> getQolariTagConfigPilotGetDimensionSchema merchantId city :<|> postQolariTagConfigPilotCreateRow merchantId city

postQolariTagTagCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.CreateQolariTagRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTagCreate a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagTagCreate a3 a2 a1

postQolariTagTagUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.UpdateQolariTagRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTagUpdate a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagTagUpdate a3 a2 a1

postQolariTagTagVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.VerifyQolariTagRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.VerifyQolariTagResponse)
postQolariTagTagVerify a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagTagVerify a3 a2 a1

deleteQolariTagTagDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTagDelete a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.deleteQolariTagTagDelete a3 a2 a1

getQolariTagTagAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowHandler [Lib.Yudhishthira.Types.QolariTagDetailsResp])
getQolariTagTagAll a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagTagAll a2 a1

getQolariTagTagDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagDetailsResp)
getQolariTagTagDetails a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagTagDetails a3 a2 a1

postQolariTagQueryCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ChakraQueriesAPIEntity -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryCreate a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagQueryCreate a3 a2 a1

postQolariTagQueryUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ChakraQueryUpdateReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryUpdate a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagQueryUpdate a3 a2 a1

deleteQolariTagQueryDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ChakraQueryDeleteReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagQueryDelete a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.deleteQolariTagQueryDelete a3 a2 a1

getQolariTagQueryDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.Chakra -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueriesAPIEntity)
getQolariTagQueryDetails a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagQueryDetails a4 a3 a2 a1

postQolariTagAppDynamicLogicVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.AppDynamicLogicReq -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicResp)
postQolariTagAppDynamicLogicVerify a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagAppDynamicLogicVerify a3 a2 a1

getQolariTagAppDynamicLogic :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.GetLogicsResp])
getQolariTagAppDynamicLogic a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogic a4 a3 a2 a1

postQolariTagRunJob :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.RunKaalChakraJobReq -> Environment.FlowHandler Lib.Yudhishthira.Types.RunKaalChakraJobRes)
postQolariTagRunJob a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagRunJob a3 a2 a1

getQolariTagTimeBounds :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.TimeBoundResp)
getQolariTagTimeBounds a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagTimeBounds a3 a2 a1

postQolariTagTimeBoundsCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.CreateTimeBoundRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTimeBoundsCreate a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagTimeBoundsCreate a3 a2 a1

deleteQolariTagTimeBoundsDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.LogicDomain -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTimeBoundsDelete a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.deleteQolariTagTimeBoundsDelete a4 a3 a2 a1

getQolariTagAppDynamicLogicGetLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Kernel.Prelude.Maybe (Kernel.Prelude.Text) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicRolloutObject])
getQolariTagAppDynamicLogicGetLogicRollout a5 a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogicGetLogicRollout a5 a4 a3 a2 a1

postQolariTagAppDynamicLogicUpsertLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.LogicRolloutReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagAppDynamicLogicUpsertLogicRollout a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagAppDynamicLogicUpsertLogicRollout a3 a2 a1

getQolariTagAppDynamicLogicVersions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicVersionResp)
getQolariTagAppDynamicLogicVersions a5 a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogicVersions a5 a4 a3 a2 a1

getQolariTagAppDynamicLogicDomains :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicDomainResp)
getQolariTagAppDynamicLogicDomains a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogicDomains a2 a1

getQolariTagAppDynamicLogicDomainsAndEvents :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp)
getQolariTagAppDynamicLogicDomainsAndEvents a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogicDomainsAndEvents a3 a2 a1

getQolariTagAppDynamicLogicGetDomainSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagAppDynamicLogicGetDomainSchema a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagAppDynamicLogicGetDomainSchema a3 a2 a1

getQolariTagQueryAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.Chakra -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueryResp)
getQolariTagQueryAll a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagQueryAll a3 a2 a1

postQolariTagUpdateCustomerTag :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Types.Id.Id Dashboard.Common.User -> Lib.Yudhishthira.Types.UpdateTagReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagUpdateCustomerTag a4 a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagUpdateCustomerTag a4 a3 a2 a1

postQolariTagConfigPilotGetVersion :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigGetVersionResponse)
postQolariTagConfigPilotGetVersion a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotGetVersion a3 a2 a1

postQolariTagConfigPilotGetConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigResponse)
postQolariTagConfigPilotGetConfig a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotGetConfig a3 a2 a1

postQolariTagConfigPilotCreateUiConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.CreateConfigRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateUiConfig a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotCreateUiConfig a3 a2 a1

getQolariTagConfigPilotAllConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigType])
getQolariTagConfigPilotAllConfigs a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotAllConfigs a3 a2 a1

getQolariTagConfigPilotConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotConfigDetails a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotConfigDetails a3 a2 a1

getQolariTagConfigPilotGetTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetTableData a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotGetTableData a3 a2 a1

getQolariTagConfigPilotAllUiConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicDomain])
getQolariTagConfigPilotAllUiConfigs a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotAllUiConfigs a3 a2 a1

getQolariTagConfigPilotUiConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotUiConfigDetails a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotUiConfigDetails a3 a2 a1

getQolariTagConfigPilotGetUiTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetUiTableData a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotGetUiTableData a3 a2 a1

getQolariTagConfigPilotAlwaysOnList :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AlwaysOnListResp)
getQolariTagConfigPilotAlwaysOnList a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotAlwaysOnList a3 a2 a1

postQolariTagConfigPilotActionChange :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ActionChangeRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotActionChange a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotActionChange a3 a2 a1

postQolariTagConfigPilotGetConfigWithDimensions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
postQolariTagConfigPilotGetConfigWithDimensions a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotGetConfigWithDimensions a3 a2 a1

getQolariTagConfigPilotGetDimensionSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagConfigPilotGetDimensionSchema a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.getQolariTagConfigPilotGetDimensionSchema a3 a2 a1

postQolariTagConfigPilotCreateRow :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateRow a3 a2 a1 = withDashboardFlowHandlerAPI $ Domain.Action.Dashboard.QolariTag.postQolariTagConfigPilotCreateRow a3 a2 a1
