{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module API.Action.RiderPlatform.Management.QolariTag
  ( API,
    handler,
  )
where

import qualified API.Types.RiderPlatform.Management
import qualified API.Types.RiderPlatform.Management.QolariTag
import qualified Dashboard.Common
import qualified Domain.Action.RiderPlatform.Management.QolariTag
import qualified "lib-dashboard" Domain.Types.Merchant
import qualified "lib-dashboard" Environment
import EulerHS.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.APISuccess
import qualified Kernel.Types.Beckn.Context
import qualified Kernel.Types.Id
import Kernel.Utils.Common
import qualified Lib.Yudhishthira.Types
import Servant
import Storage.Beam.CommonInstances ()
import Tools.Auth.Api

type API = ("QolariTag" :> (PostQolariTagTagCreate :<|> PostQolariTagTagUpdate :<|> PostQolariTagTagVerify :<|> DeleteQolariTagTagDelete :<|> GetQolariTagTagAll :<|> GetQolariTagTagDetails :<|> PostQolariTagQueryCreate :<|> PostQolariTagQueryUpdate :<|> DeleteQolariTagQueryDelete :<|> GetQolariTagQueryDetails :<|> PostQolariTagAppDynamicLogicVerify :<|> GetQolariTagAppDynamicLogic :<|> PostQolariTagRunJob :<|> GetQolariTagTimeBounds :<|> PostQolariTagTimeBoundsCreate :<|> DeleteQolariTagTimeBoundsDelete :<|> GetQolariTagAppDynamicLogicGetLogicRollout :<|> PostQolariTagAppDynamicLogicUpsertLogicRollout :<|> GetQolariTagAppDynamicLogicVersions :<|> GetQolariTagAppDynamicLogicDomains :<|> GetQolariTagAppDynamicLogicDomainsAndEvents :<|> GetQolariTagAppDynamicLogicGetDomainSchema :<|> GetQolariTagQueryAll :<|> PostQolariTagUpdateCustomerTag :<|> PostQolariTagConfigPilotGetVersion :<|> PostQolariTagConfigPilotGetConfig :<|> PostQolariTagConfigPilotCreateUiConfig :<|> GetQolariTagConfigPilotAllConfigs :<|> GetQolariTagConfigPilotConfigDetails :<|> GetQolariTagConfigPilotGetTableData :<|> GetQolariTagConfigPilotAllUiConfigs :<|> GetQolariTagConfigPilotUiConfigDetails :<|> GetQolariTagConfigPilotGetUiTableData :<|> GetQolariTagConfigPilotAlwaysOnList :<|> PostQolariTagConfigPilotActionChange :<|> PostQolariTagConfigPilotGetConfigWithDimensions :<|> GetQolariTagConfigPilotGetDimensionSchema :<|> PostQolariTagConfigPilotCreateRow))

handler :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowServer API)
handler merchantId city = postQolariTagTagCreate merchantId city :<|> postQolariTagTagUpdate merchantId city :<|> postQolariTagTagVerify merchantId city :<|> deleteQolariTagTagDelete merchantId city :<|> getQolariTagTagAll merchantId city :<|> getQolariTagTagDetails merchantId city :<|> postQolariTagQueryCreate merchantId city :<|> postQolariTagQueryUpdate merchantId city :<|> deleteQolariTagQueryDelete merchantId city :<|> getQolariTagQueryDetails merchantId city :<|> postQolariTagAppDynamicLogicVerify merchantId city :<|> getQolariTagAppDynamicLogic merchantId city :<|> postQolariTagRunJob merchantId city :<|> getQolariTagTimeBounds merchantId city :<|> postQolariTagTimeBoundsCreate merchantId city :<|> deleteQolariTagTimeBoundsDelete merchantId city :<|> getQolariTagAppDynamicLogicGetLogicRollout merchantId city :<|> postQolariTagAppDynamicLogicUpsertLogicRollout merchantId city :<|> getQolariTagAppDynamicLogicVersions merchantId city :<|> getQolariTagAppDynamicLogicDomains merchantId city :<|> getQolariTagAppDynamicLogicDomainsAndEvents merchantId city :<|> getQolariTagAppDynamicLogicGetDomainSchema merchantId city :<|> getQolariTagQueryAll merchantId city :<|> postQolariTagUpdateCustomerTag merchantId city :<|> postQolariTagConfigPilotGetVersion merchantId city :<|> postQolariTagConfigPilotGetConfig merchantId city :<|> postQolariTagConfigPilotCreateUiConfig merchantId city :<|> getQolariTagConfigPilotAllConfigs merchantId city :<|> getQolariTagConfigPilotConfigDetails merchantId city :<|> getQolariTagConfigPilotGetTableData merchantId city :<|> getQolariTagConfigPilotAllUiConfigs merchantId city :<|> getQolariTagConfigPilotUiConfigDetails merchantId city :<|> getQolariTagConfigPilotGetUiTableData merchantId city :<|> getQolariTagConfigPilotAlwaysOnList merchantId city :<|> postQolariTagConfigPilotActionChange merchantId city :<|> postQolariTagConfigPilotGetConfigWithDimensions merchantId city :<|> getQolariTagConfigPilotGetDimensionSchema merchantId city :<|> postQolariTagConfigPilotCreateRow merchantId city

type PostQolariTagTagCreate =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_CREATE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagTagCreate
  )

type PostQolariTagTagUpdate =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_UPDATE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagTagUpdate
  )

type PostQolariTagTagVerify =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_VERIFY))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagTagVerify
  )

type DeleteQolariTagTagDelete =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_TAG_DELETE))
      :> API.Types.RiderPlatform.Management.QolariTag.DeleteQolariTagTagDelete
  )

type GetQolariTagTagAll =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_TAG_ALL))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagTagAll
  )

type GetQolariTagTagDetails =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_TAG_DETAILS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagTagDetails
  )

type PostQolariTagQueryCreate =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_QUERY_CREATE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagQueryCreate
  )

type PostQolariTagQueryUpdate =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_QUERY_UPDATE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagQueryUpdate
  )

type DeleteQolariTagQueryDelete =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_QUERY_DELETE))
      :> API.Types.RiderPlatform.Management.QolariTag.DeleteQolariTagQueryDelete
  )

type GetQolariTagQueryDetails =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_QUERY_DETAILS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagQueryDetails
  )

type PostQolariTagAppDynamicLogicVerify =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERIFY))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagAppDynamicLogicVerify
  )

type GetQolariTagAppDynamicLogic =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogic
  )

type PostQolariTagRunJob =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_RUN_JOB))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagRunJob
  )

type GetQolariTagTimeBounds =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_TIME_BOUNDS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagTimeBounds
  )

type PostQolariTagTimeBoundsCreate =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_TIME_BOUNDS_CREATE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagTimeBoundsCreate
  )

type DeleteQolariTagTimeBoundsDelete =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_TIME_BOUNDS_DELETE))
      :> API.Types.RiderPlatform.Management.QolariTag.DeleteQolariTagTimeBoundsDelete
  )

type GetQolariTagAppDynamicLogicGetLogicRollout =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_LOGIC_ROLLOUT))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicGetLogicRollout
  )

type PostQolariTagAppDynamicLogicUpsertLogicRollout =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_UPSERT_LOGIC_ROLLOUT))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagAppDynamicLogicUpsertLogicRollout
  )

type GetQolariTagAppDynamicLogicVersions =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERSIONS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicVersions
  )

type GetQolariTagAppDynamicLogicDomains =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicDomains
  )

type GetQolariTagAppDynamicLogicDomainsAndEvents =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS_AND_EVENTS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicDomainsAndEvents
  )

type GetQolariTagAppDynamicLogicGetDomainSchema =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_DOMAIN_SCHEMA))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicGetDomainSchema
  )

type GetQolariTagQueryAll =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_QUERY_ALL))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagQueryAll
  )

type PostQolariTagUpdateCustomerTag =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_UPDATE_CUSTOMER_TAG))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagUpdateCustomerTag
  )

type PostQolariTagConfigPilotGetVersion =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_VERSION))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetVersion
  )

type PostQolariTagConfigPilotGetConfig =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetConfig
  )

type PostQolariTagConfigPilotCreateUiConfig =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_CREATE_UI_CONFIG))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotCreateUiConfig
  )

type GetQolariTagConfigPilotAllConfigs =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALL_CONFIGS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotAllConfigs
  )

type GetQolariTagConfigPilotConfigDetails =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_CONFIG_DETAILS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotConfigDetails
  )

type GetQolariTagConfigPilotGetTableData =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_TABLE_DATA))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetTableData
  )

type GetQolariTagConfigPilotAllUiConfigs =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALL_UI_CONFIGS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotAllUiConfigs
  )

type GetQolariTagConfigPilotUiConfigDetails =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_UI_CONFIG_DETAILS))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotUiConfigDetails
  )

type GetQolariTagConfigPilotGetUiTableData =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_UI_TABLE_DATA))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetUiTableData
  )

type GetQolariTagConfigPilotAlwaysOnList =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALWAYS_ON_LIST))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotAlwaysOnList
  )

type PostQolariTagConfigPilotActionChange =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotActionChange
  )

type PostQolariTagConfigPilotGetConfigWithDimensions =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG_WITH_DIMENSIONS))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetConfigWithDimensions
  )

type GetQolariTagConfigPilotGetDimensionSchema =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_DIMENSION_SCHEMA))
      :> API.Types.RiderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetDimensionSchema
  )

type PostQolariTagConfigPilotCreateRow =
  ( ApiAuth
      ('APP_BACKEND_MANAGEMENT)
      ('DSL)
      (('RIDER_MANAGEMENT) / ('API.Types.RiderPlatform.Management.QOLARI_TAG) / ('API.Types.RiderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_CREATE_ROW))
      :> API.Types.RiderPlatform.Management.QolariTag.PostQolariTagConfigPilotCreateRow
  )

postQolariTagTagCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateQolariTagRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTagCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagTagCreate merchantShortId opCity apiTokenInfo req

postQolariTagTagUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UpdateQolariTagRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTagUpdate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagTagUpdate merchantShortId opCity apiTokenInfo req

postQolariTagTagVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.VerifyQolariTagRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.VerifyQolariTagResponse)
postQolariTagTagVerify merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagTagVerify merchantShortId opCity apiTokenInfo req

deleteQolariTagTagDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTagDelete merchantShortId opCity apiTokenInfo tagName = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.deleteQolariTagTagDelete merchantShortId opCity apiTokenInfo tagName

getQolariTagTagAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.FlowHandler [Lib.Yudhishthira.Types.QolariTagDetailsResp])
getQolariTagTagAll merchantShortId opCity apiTokenInfo = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagTagAll merchantShortId opCity apiTokenInfo

getQolariTagTagDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagDetailsResp)
getQolariTagTagDetails merchantShortId opCity apiTokenInfo tagName = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagTagDetails merchantShortId opCity apiTokenInfo tagName

postQolariTagQueryCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueriesAPIEntity -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagQueryCreate merchantShortId opCity apiTokenInfo req

postQolariTagQueryUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryUpdateReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryUpdate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagQueryUpdate merchantShortId opCity apiTokenInfo req

deleteQolariTagQueryDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryDeleteReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagQueryDelete merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.deleteQolariTagQueryDelete merchantShortId opCity apiTokenInfo req

getQolariTagQueryDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueriesAPIEntity)
getQolariTagQueryDetails merchantShortId opCity apiTokenInfo chakra queryName = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagQueryDetails merchantShortId opCity apiTokenInfo chakra queryName

postQolariTagAppDynamicLogicVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.AppDynamicLogicReq -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicResp)
postQolariTagAppDynamicLogicVerify merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagAppDynamicLogicVerify merchantShortId opCity apiTokenInfo req

getQolariTagAppDynamicLogic :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.GetLogicsResp])
getQolariTagAppDynamicLogic merchantShortId opCity apiTokenInfo version domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogic merchantShortId opCity apiTokenInfo version domain

postQolariTagRunJob :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.RunKaalChakraJobReq -> Environment.FlowHandler Lib.Yudhishthira.Types.RunKaalChakraJobRes)
postQolariTagRunJob merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagRunJob merchantShortId opCity apiTokenInfo req

getQolariTagTimeBounds :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.TimeBoundResp)
getQolariTagTimeBounds merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagTimeBounds merchantShortId opCity apiTokenInfo domain

postQolariTagTimeBoundsCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateTimeBoundRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTimeBoundsCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagTimeBoundsCreate merchantShortId opCity apiTokenInfo req

deleteQolariTagTimeBoundsDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTimeBoundsDelete merchantShortId opCity apiTokenInfo domain name = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.deleteQolariTagTimeBoundsDelete merchantShortId opCity apiTokenInfo domain name

getQolariTagAppDynamicLogicGetLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Kernel.Prelude.Maybe (Kernel.Prelude.Text) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicRolloutObject])
getQolariTagAppDynamicLogicGetLogicRollout merchantShortId opCity apiTokenInfo activeOnly timeBound domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicGetLogicRollout merchantShortId opCity apiTokenInfo activeOnly timeBound domain

postQolariTagAppDynamicLogicUpsertLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicRolloutReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagAppDynamicLogicUpsertLogicRollout merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagAppDynamicLogicUpsertLogicRollout merchantShortId opCity apiTokenInfo req

getQolariTagAppDynamicLogicVersions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Kernel.Prelude.Maybe (Kernel.Prelude.Int) -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicVersionResp)
getQolariTagAppDynamicLogicVersions merchantShortId opCity apiTokenInfo limit offset domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicVersions merchantShortId opCity apiTokenInfo limit offset domain

getQolariTagAppDynamicLogicDomains :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicDomainResp)
getQolariTagAppDynamicLogicDomains merchantShortId opCity apiTokenInfo = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicDomains merchantShortId opCity apiTokenInfo

getQolariTagAppDynamicLogicDomainsAndEvents :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp)
getQolariTagAppDynamicLogicDomainsAndEvents merchantShortId opCity apiTokenInfo fetchQolariTagNames = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicDomainsAndEvents merchantShortId opCity apiTokenInfo fetchQolariTagNames

getQolariTagAppDynamicLogicGetDomainSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagAppDynamicLogicGetDomainSchema merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicGetDomainSchema merchantShortId opCity apiTokenInfo domain

getQolariTagQueryAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueryResp)
getQolariTagQueryAll merchantShortId opCity apiTokenInfo chakra = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagQueryAll merchantShortId opCity apiTokenInfo chakra

postQolariTagUpdateCustomerTag :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Types.Id.Id Dashboard.Common.User -> Lib.Yudhishthira.Types.UpdateTagReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagUpdateCustomerTag merchantShortId opCity apiTokenInfo customerId req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagUpdateCustomerTag merchantShortId opCity apiTokenInfo customerId req

postQolariTagConfigPilotGetVersion :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigGetVersionResponse)
postQolariTagConfigPilotGetVersion merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotGetVersion merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotGetConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigResponse)
postQolariTagConfigPilotGetConfig merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotGetConfig merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotCreateUiConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateConfigRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateUiConfig merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotCreateUiConfig merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotAllConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigType])
getQolariTagConfigPilotAllConfigs merchantShortId opCity apiTokenInfo underExperiment = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotAllConfigs merchantShortId opCity apiTokenInfo underExperiment

getQolariTagConfigPilotConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotConfigDetails merchantShortId opCity apiTokenInfo tableName = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotConfigDetails merchantShortId opCity apiTokenInfo tableName

getQolariTagConfigPilotGetTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetTableData merchantShortId opCity apiTokenInfo tableName = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotGetTableData merchantShortId opCity apiTokenInfo tableName

getQolariTagConfigPilotAllUiConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe (Kernel.Prelude.Bool) -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicDomain])
getQolariTagConfigPilotAllUiConfigs merchantShortId opCity apiTokenInfo underExperiment = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotAllUiConfigs merchantShortId opCity apiTokenInfo underExperiment

getQolariTagConfigPilotUiConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotUiConfigDetails merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotUiConfigDetails merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotGetUiTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetUiTableData merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotGetUiTableData merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotAlwaysOnList :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AlwaysOnListResp)
getQolariTagConfigPilotAlwaysOnList merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotAlwaysOnList merchantShortId opCity apiTokenInfo domain

postQolariTagConfigPilotActionChange :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ActionChangeRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotActionChange merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotActionChange merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotGetConfigWithDimensions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
postQolariTagConfigPilotGetConfigWithDimensions merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotGetConfigWithDimensions merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotGetDimensionSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagConfigPilotGetDimensionSchema merchantShortId opCity apiTokenInfo configType = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.getQolariTagConfigPilotGetDimensionSchema merchantShortId opCity apiTokenInfo configType

postQolariTagConfigPilotCreateRow :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateRow merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.RiderPlatform.Management.QolariTag.postQolariTagConfigPilotCreateRow merchantShortId opCity apiTokenInfo req
