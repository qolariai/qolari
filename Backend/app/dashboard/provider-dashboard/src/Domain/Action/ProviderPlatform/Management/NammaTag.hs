{-# OPTIONS_GHC -Wno-orphans #-}

module Domain.Action.ProviderPlatform.Management.QolariTag
  ( postQolariTagTagCreate,
    postQolariTagTagVerify,
    postQolariTagQueryCreate,
    postQolariTagQueryUpdate,
    deleteQolariTagQueryDelete,
    postQolariTagAppDynamicLogicVerify,
    getQolariTagAppDynamicLogic,
    postQolariTagRunJob,
    postQolariTagTagUpdate,
    deleteQolariTagTagDelete,
    postQolariTagTimeBoundsCreate,
    deleteQolariTagTimeBoundsDelete,
    getQolariTagAppDynamicLogicGetLogicRollout,
    postQolariTagAppDynamicLogicUpsertLogicRollout,
    getQolariTagTimeBounds,
    getQolariTagAppDynamicLogicVersions,
    getQolariTagAppDynamicLogicDomains,
    getQolariTagAppDynamicLogicGetDomainSchema,
    getQolariTagQueryAll,
    postQolariTagConfigPilotGetConfig,
    postQolariTagConfigPilotGetVersion,
    postQolariTagConfigPilotCreateUiConfig,
    getQolariTagConfigPilotAllConfigs,
    getQolariTagConfigPilotConfigDetails,
    getQolariTagConfigPilotGetTableData,
    postQolariTagConfigPilotActionChange,
    getQolariTagConfigPilotAllUiConfigs,
    getQolariTagConfigPilotUiConfigDetails,
    getQolariTagConfigPilotGetUiTableData,
    postQolariTagConfigPilotGetPatchedElement,
    getQolariTagAppDynamicLogicDomainsAndEvents,
    getQolariTagTagAll,
    getQolariTagConfigPilotAlwaysOnList,
    getQolariTagTagDetails,
    getQolariTagQueryDetails,
    getQolariTagBehaviorVisibility,
    postQolariTagConfigPilotGetConfigWithDimensions,
    getQolariTagConfigPilotGetDimensionSchema,
    postQolariTagConfigPilotCreateRow,
  )
where

import qualified API.Client.ProviderPlatform.Management
import qualified "lib-dashboard" Domain.Types.Merchant
import qualified Domain.Types.Transaction
import qualified "lib-dashboard" Environment
import EulerHS.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.APISuccess
import qualified Kernel.Types.Beckn.Context
import qualified Kernel.Types.Id
import qualified Lib.BehaviorTracker.Types
import qualified Lib.Yudhishthira.Types
import qualified SharedLogic.Transaction
import Storage.Beam.CommonInstances ()
import Tools.Auth.Api
import Tools.Auth.Merchant

postQolariTagTagCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateQolariTagRequest -> Environment.Flow Lib.Yudhishthira.Types.CreateQolariTagResponse)
postQolariTagTagCreate merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagTagCreate) req)

postQolariTagTagVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.VerifyQolariTagRequest -> Environment.Flow Lib.Yudhishthira.Types.VerifyQolariTagResponse)
postQolariTagTagVerify merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagTagVerify) req)

postQolariTagQueryCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueriesAPIEntity -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryCreate merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagQueryCreate) req)

postQolariTagAppDynamicLogicVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.AppDynamicLogicReq -> Environment.Flow Lib.Yudhishthira.Types.AppDynamicLogicResp)
postQolariTagAppDynamicLogicVerify merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagAppDynamicLogicVerify) req)

getQolariTagAppDynamicLogic :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Maybe Int -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow [Lib.Yudhishthira.Types.GetLogicsResp])
getQolariTagAppDynamicLogic merchantShortId opCity apiTokenInfo version domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogic) version domain

postQolariTagRunJob :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.RunKaalChakraJobReq -> Environment.Flow Lib.Yudhishthira.Types.RunKaalChakraJobRes)
postQolariTagRunJob merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagRunJob) req)

postQolariTagTagUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UpdateQolariTagRequest -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagTagUpdate merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagTagUpdate) req)

deleteQolariTagTagDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTagDelete merchantShortId opCity apiTokenInfo tagName = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing SharedLogic.Transaction.emptyRequest
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.deleteQolariTagTagDelete) tagName)

postQolariTagTimeBoundsCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateTimeBoundRequest -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagTimeBoundsCreate merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagTimeBoundsCreate) req)

deleteQolariTagTimeBoundsDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Kernel.Prelude.Text -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTimeBoundsDelete merchantShortId opCity apiTokenInfo domain name = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing SharedLogic.Transaction.emptyRequest
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.deleteQolariTagTimeBoundsDelete) domain name)

getQolariTagAppDynamicLogicGetLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Kernel.Prelude.Maybe (Kernel.Prelude.Text) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow [Lib.Yudhishthira.Types.LogicRolloutObject])
getQolariTagAppDynamicLogicGetLogicRollout merchantShortId opCity apiTokenInfo activeOnly timeBound domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogicGetLogicRollout) activeOnly timeBound domain

postQolariTagAppDynamicLogicUpsertLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> [Lib.Yudhishthira.Types.LogicRolloutObject] -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagAppDynamicLogicUpsertLogicRollout merchantShortId opCity apiTokenInfo req = do
  let updatedReq = map (\r -> r{modifiedBy = Just (Kernel.Types.Id.cast apiTokenInfo.personId)}) req
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just updatedReq)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagAppDynamicLogicUpsertLogicRollout) updatedReq)

getQolariTagTimeBounds :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow Lib.Yudhishthira.Types.TimeBoundResp)
getQolariTagTimeBounds merchantShortId opCity apiTokenInfo domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagTimeBounds) domain

getQolariTagAppDynamicLogicVersions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow Lib.Yudhishthira.Types.AppDynamicLogicVersionResp)
getQolariTagAppDynamicLogicVersions merchantShortId opCity apiTokenInfo limit offset domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogicVersions) limit offset domain

getQolariTagAppDynamicLogicDomains :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.Flow Lib.Yudhishthira.Types.AppDynamicLogicDomainResp)
getQolariTagAppDynamicLogicDomains merchantShortId opCity apiTokenInfo = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogicDomains)

getQolariTagQueryAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Environment.Flow Lib.Yudhishthira.Types.ChakraQueryResp)
getQolariTagQueryAll merchantShortId opCity apiTokenInfo chakra = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagQueryAll) chakra

postQolariTagConfigPilotGetVersion :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.Flow Lib.Yudhishthira.Types.UiConfigGetVersionResponse)
postQolariTagConfigPilotGetVersion merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotGetVersion) req)

postQolariTagConfigPilotGetConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.Flow Lib.Yudhishthira.Types.UiConfigResponse)
postQolariTagConfigPilotGetConfig merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotGetConfig) req)

postQolariTagConfigPilotCreateUiConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateConfigRequest -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateUiConfig merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotCreateUiConfig) req)

getQolariTagConfigPilotAllConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Environment.Flow [Lib.Yudhishthira.Types.ConfigType])
getQolariTagConfigPilotAllConfigs merchantShortId opCity apiTokenInfo underExperiment = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotAllConfigs) underExperiment

getQolariTagConfigPilotConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.Flow [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotConfigDetails merchantShortId opCity apiTokenInfo tableName = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotConfigDetails) tableName

getQolariTagConfigPilotGetTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.Flow Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetTableData merchantShortId opCity apiTokenInfo tableName = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotGetTableData) tableName

postQolariTagConfigPilotActionChange :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ActionChangeRequest -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotActionChange merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotActionChange) req)

postQolariTagQueryUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryUpdateReq -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryUpdate merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagQueryUpdate) req)

deleteQolariTagQueryDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryDeleteReq -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
deleteQolariTagQueryDelete merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.deleteQolariTagQueryDelete) req)

getQolariTagConfigPilotAllUiConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.Flow [Lib.Yudhishthira.Types.LogicDomain])
getQolariTagConfigPilotAllUiConfigs merchantShortId opCity apiTokenInfo underExperiment = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotAllUiConfigs) underExperiment

getQolariTagConfigPilotUiConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.Flow [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotUiConfigDetails merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotUiConfigDetails) req

getQolariTagConfigPilotGetUiTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.Flow Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetUiTableData merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotGetUiTableData) req

postQolariTagConfigPilotGetPatchedElement :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.GetPatchedElementReq -> Environment.Flow Lib.Yudhishthira.Types.GetPatchedElementResp)
postQolariTagConfigPilotGetPatchedElement merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotGetPatchedElement) req)

getQolariTagAppDynamicLogicGetDomainSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagAppDynamicLogicGetDomainSchema merchantShortId opCity apiTokenInfo domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogicGetDomainSchema) domain

getQolariTagAppDynamicLogicDomainsAndEvents :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.Flow Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp)
getQolariTagAppDynamicLogicDomainsAndEvents merchantShortId opCity apiTokenInfo fetchQolariTagNames = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagAppDynamicLogicDomainsAndEvents) fetchQolariTagNames

getQolariTagTagAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.Flow [Lib.Yudhishthira.Types.QolariTagDetailsResp])
getQolariTagTagAll merchantShortId opCity apiTokenInfo = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagTagAll)

getQolariTagConfigPilotAlwaysOnList :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.Flow Lib.Yudhishthira.Types.AlwaysOnListResp)
getQolariTagConfigPilotAlwaysOnList merchantShortId opCity apiTokenInfo domain = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotAlwaysOnList) domain

getQolariTagTagDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.Flow Lib.Yudhishthira.Types.QolariTagDetailsResp)
getQolariTagTagDetails merchantShortId opCity apiTokenInfo tagName = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagTagDetails) tagName

getQolariTagQueryDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Kernel.Prelude.Text -> Environment.Flow Lib.Yudhishthira.Types.ChakraQueriesAPIEntity)
getQolariTagQueryDetails merchantShortId opCity apiTokenInfo chakra queryName = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagQueryDetails) chakra queryName

getQolariTagBehaviorVisibility :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Kernel.Prelude.Text -> Environment.Flow Lib.BehaviorTracker.Types.EntityBehaviorVisibility)
getQolariTagBehaviorVisibility merchantShortId opCity apiTokenInfo entityType entityId = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagBehaviorVisibility) entityType entityId

postQolariTagConfigPilotGetConfigWithDimensions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest -> Environment.Flow Lib.Yudhishthira.Types.TableDataResp)
postQolariTagConfigPilotGetConfigWithDimensions merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotGetConfigWithDimensions) req)

getQolariTagConfigPilotGetDimensionSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.Flow Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagConfigPilotGetDimensionSchema merchantShortId opCity apiTokenInfo configType = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.getQolariTagConfigPilotGetDimensionSchema) configType

postQolariTagConfigPilotCreateRow :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest -> Environment.Flow Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateRow merchantShortId opCity apiTokenInfo req = do
  checkedMerchantId <- merchantCityAccessCheck merchantShortId apiTokenInfo.merchant.shortId opCity apiTokenInfo.city
  transaction <- SharedLogic.Transaction.buildTransaction (Domain.Types.Transaction.castEndpoint apiTokenInfo.userActionType) (Kernel.Prelude.Just DRIVER_OFFER_BPP_MANAGEMENT) (Kernel.Prelude.Just apiTokenInfo) Kernel.Prelude.Nothing Kernel.Prelude.Nothing (Kernel.Prelude.Just req)
  SharedLogic.Transaction.withTransactionStoring transaction $ (do API.Client.ProviderPlatform.Management.callManagementAPI checkedMerchantId opCity (.QolariTagDSL.postQolariTagConfigPilotCreateRow) req)
