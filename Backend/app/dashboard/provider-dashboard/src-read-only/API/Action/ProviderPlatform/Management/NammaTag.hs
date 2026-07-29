{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module API.Action.ProviderPlatform.Management.QolariTag
  ( API,
    handler,
  )
where

import qualified API.Types.ProviderPlatform.Management
import qualified API.Types.ProviderPlatform.Management.QolariTag
import qualified Domain.Action.ProviderPlatform.Management.QolariTag
import qualified "lib-dashboard" Domain.Types.Merchant
import qualified "lib-dashboard" Environment
import EulerHS.Prelude hiding (sortOn)
import qualified Kernel.Prelude
import qualified Kernel.Types.APISuccess
import qualified Kernel.Types.Beckn.Context
import qualified Kernel.Types.Id
import Kernel.Utils.Common hiding (INFO)
import qualified Lib.BehaviorTracker.Types
import qualified Lib.Yudhishthira.Types
import Servant
import Storage.Beam.CommonInstances ()
import Tools.Auth.Api

type API = ("QolariTag" :> (PostQolariTagTagCreate :<|> PostQolariTagTagVerify :<|> PostQolariTagTagUpdate :<|> DeleteQolariTagTagDelete :<|> GetQolariTagTagAll :<|> GetQolariTagTagDetails :<|> PostQolariTagQueryCreate :<|> PostQolariTagQueryUpdate :<|> DeleteQolariTagQueryDelete :<|> GetQolariTagQueryDetails :<|> PostQolariTagAppDynamicLogicVerify :<|> GetQolariTagAppDynamicLogic :<|> PostQolariTagRunJob :<|> GetQolariTagTimeBounds :<|> PostQolariTagTimeBoundsCreate :<|> DeleteQolariTagTimeBoundsDelete :<|> GetQolariTagAppDynamicLogicGetLogicRollout :<|> PostQolariTagAppDynamicLogicUpsertLogicRollout :<|> GetQolariTagAppDynamicLogicVersions :<|> GetQolariTagAppDynamicLogicDomains :<|> GetQolariTagAppDynamicLogicDomainsAndEvents :<|> GetQolariTagAppDynamicLogicGetDomainSchema :<|> GetQolariTagQueryAll :<|> PostQolariTagConfigPilotGetVersion :<|> PostQolariTagConfigPilotGetConfig :<|> PostQolariTagConfigPilotCreateUiConfig :<|> GetQolariTagConfigPilotAllConfigs :<|> GetQolariTagConfigPilotConfigDetails :<|> GetQolariTagConfigPilotGetTableData :<|> GetQolariTagConfigPilotAllUiConfigs :<|> GetQolariTagConfigPilotUiConfigDetails :<|> GetQolariTagConfigPilotGetUiTableData :<|> GetQolariTagConfigPilotAlwaysOnList :<|> PostQolariTagConfigPilotActionChange :<|> PostQolariTagConfigPilotGetPatchedElement :<|> PostQolariTagConfigPilotGetConfigWithDimensions :<|> GetQolariTagConfigPilotGetDimensionSchema :<|> PostQolariTagConfigPilotCreateRow :<|> GetQolariTagBehaviorVisibility))

handler :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> Environment.FlowServer API)
handler merchantId city = postQolariTagTagCreate merchantId city :<|> postQolariTagTagVerify merchantId city :<|> postQolariTagTagUpdate merchantId city :<|> deleteQolariTagTagDelete merchantId city :<|> getQolariTagTagAll merchantId city :<|> getQolariTagTagDetails merchantId city :<|> postQolariTagQueryCreate merchantId city :<|> postQolariTagQueryUpdate merchantId city :<|> deleteQolariTagQueryDelete merchantId city :<|> getQolariTagQueryDetails merchantId city :<|> postQolariTagAppDynamicLogicVerify merchantId city :<|> getQolariTagAppDynamicLogic merchantId city :<|> postQolariTagRunJob merchantId city :<|> getQolariTagTimeBounds merchantId city :<|> postQolariTagTimeBoundsCreate merchantId city :<|> deleteQolariTagTimeBoundsDelete merchantId city :<|> getQolariTagAppDynamicLogicGetLogicRollout merchantId city :<|> postQolariTagAppDynamicLogicUpsertLogicRollout merchantId city :<|> getQolariTagAppDynamicLogicVersions merchantId city :<|> getQolariTagAppDynamicLogicDomains merchantId city :<|> getQolariTagAppDynamicLogicDomainsAndEvents merchantId city :<|> getQolariTagAppDynamicLogicGetDomainSchema merchantId city :<|> getQolariTagQueryAll merchantId city :<|> postQolariTagConfigPilotGetVersion merchantId city :<|> postQolariTagConfigPilotGetConfig merchantId city :<|> postQolariTagConfigPilotCreateUiConfig merchantId city :<|> getQolariTagConfigPilotAllConfigs merchantId city :<|> getQolariTagConfigPilotConfigDetails merchantId city :<|> getQolariTagConfigPilotGetTableData merchantId city :<|> getQolariTagConfigPilotAllUiConfigs merchantId city :<|> getQolariTagConfigPilotUiConfigDetails merchantId city :<|> getQolariTagConfigPilotGetUiTableData merchantId city :<|> getQolariTagConfigPilotAlwaysOnList merchantId city :<|> postQolariTagConfigPilotActionChange merchantId city :<|> postQolariTagConfigPilotGetPatchedElement merchantId city :<|> postQolariTagConfigPilotGetConfigWithDimensions merchantId city :<|> getQolariTagConfigPilotGetDimensionSchema merchantId city :<|> postQolariTagConfigPilotCreateRow merchantId city :<|> getQolariTagBehaviorVisibility merchantId city

type PostQolariTagTagCreate =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_CREATE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagTagCreate
  )

type PostQolariTagTagVerify =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_VERIFY)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagTagVerify
  )

type PostQolariTagTagUpdate =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_TAG_UPDATE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagTagUpdate
  )

type DeleteQolariTagTagDelete =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_TAG_DELETE)
      :> API.Types.ProviderPlatform.Management.QolariTag.DeleteQolariTagTagDelete
  )

type GetQolariTagTagAll =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_TAG_ALL)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagTagAll
  )

type GetQolariTagTagDetails =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_TAG_DETAILS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagTagDetails
  )

type PostQolariTagQueryCreate =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_QUERY_CREATE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagQueryCreate
  )

type PostQolariTagQueryUpdate =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_QUERY_UPDATE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagQueryUpdate
  )

type DeleteQolariTagQueryDelete =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_QUERY_DELETE)
      :> API.Types.ProviderPlatform.Management.QolariTag.DeleteQolariTagQueryDelete
  )

type GetQolariTagQueryDetails =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_QUERY_DETAILS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagQueryDetails
  )

type PostQolariTagAppDynamicLogicVerify =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERIFY)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagAppDynamicLogicVerify
  )

type GetQolariTagAppDynamicLogic =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogic
  )

type PostQolariTagRunJob =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_RUN_JOB)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagRunJob
  )

type GetQolariTagTimeBounds =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_TIME_BOUNDS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagTimeBounds
  )

type PostQolariTagTimeBoundsCreate =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_TIME_BOUNDS_CREATE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagTimeBoundsCreate
  )

type DeleteQolariTagTimeBoundsDelete =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.DELETE_QOLARI_TAG_TIME_BOUNDS_DELETE)
      :> API.Types.ProviderPlatform.Management.QolariTag.DeleteQolariTagTimeBoundsDelete
  )

type GetQolariTagAppDynamicLogicGetLogicRollout =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_LOGIC_ROLLOUT)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicGetLogicRollout
  )

type PostQolariTagAppDynamicLogicUpsertLogicRollout =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_UPSERT_LOGIC_ROLLOUT)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagAppDynamicLogicUpsertLogicRollout
  )

type GetQolariTagAppDynamicLogicVersions =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERSIONS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicVersions
  )

type GetQolariTagAppDynamicLogicDomains =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicDomains
  )

type GetQolariTagAppDynamicLogicDomainsAndEvents =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS_AND_EVENTS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicDomainsAndEvents
  )

type GetQolariTagAppDynamicLogicGetDomainSchema =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_DOMAIN_SCHEMA)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagAppDynamicLogicGetDomainSchema
  )

type GetQolariTagQueryAll =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_QUERY_ALL)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagQueryAll
  )

type PostQolariTagConfigPilotGetVersion =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_VERSION)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetVersion
  )

type PostQolariTagConfigPilotGetConfig =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetConfig
  )

type PostQolariTagConfigPilotCreateUiConfig =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_CREATE_UI_CONFIG)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotCreateUiConfig
  )

type GetQolariTagConfigPilotAllConfigs =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALL_CONFIGS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotAllConfigs
  )

type GetQolariTagConfigPilotConfigDetails =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_CONFIG_DETAILS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotConfigDetails
  )

type GetQolariTagConfigPilotGetTableData =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_TABLE_DATA)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetTableData
  )

type GetQolariTagConfigPilotAllUiConfigs =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALL_UI_CONFIGS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotAllUiConfigs
  )

type GetQolariTagConfigPilotUiConfigDetails =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_UI_CONFIG_DETAILS)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotUiConfigDetails
  )

type GetQolariTagConfigPilotGetUiTableData =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_UI_TABLE_DATA)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetUiTableData
  )

type GetQolariTagConfigPilotAlwaysOnList =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_ALWAYS_ON_LIST)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotAlwaysOnList
  )

type PostQolariTagConfigPilotActionChange =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotActionChange
  )

type PostQolariTagConfigPilotGetPatchedElement =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_PATCHED_ELEMENT)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetPatchedElement
  )

type PostQolariTagConfigPilotGetConfigWithDimensions =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG_WITH_DIMENSIONS)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotGetConfigWithDimensions
  )

type GetQolariTagConfigPilotGetDimensionSchema =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_CONFIG_PILOT_GET_DIMENSION_SCHEMA)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagConfigPilotGetDimensionSchema
  )

type PostQolariTagConfigPilotCreateRow =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.POST_QOLARI_TAG_CONFIG_PILOT_CREATE_ROW)
      :> API.Types.ProviderPlatform.Management.QolariTag.PostQolariTagConfigPilotCreateRow
  )

type GetQolariTagBehaviorVisibility =
  ( ApiAuth
      'DRIVER_OFFER_BPP_MANAGEMENT
      'DSL
      ('PROVIDER_MANAGEMENT / 'API.Types.ProviderPlatform.Management.QOLARI_TAG / 'API.Types.ProviderPlatform.Management.QolariTag.GET_QOLARI_TAG_BEHAVIOR_VISIBILITY)
      :> API.Types.ProviderPlatform.Management.QolariTag.GetQolariTagBehaviorVisibility
  )

postQolariTagTagCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateQolariTagRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.CreateQolariTagResponse)
postQolariTagTagCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagTagCreate merchantShortId opCity apiTokenInfo req

postQolariTagTagVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.VerifyQolariTagRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.VerifyQolariTagResponse)
postQolariTagTagVerify merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagTagVerify merchantShortId opCity apiTokenInfo req

postQolariTagTagUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UpdateQolariTagRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTagUpdate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagTagUpdate merchantShortId opCity apiTokenInfo req

deleteQolariTagTagDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTagDelete merchantShortId opCity apiTokenInfo tagName = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.deleteQolariTagTagDelete merchantShortId opCity apiTokenInfo tagName

getQolariTagTagAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.FlowHandler [Lib.Yudhishthira.Types.QolariTagDetailsResp])
getQolariTagTagAll merchantShortId opCity apiTokenInfo = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagTagAll merchantShortId opCity apiTokenInfo

getQolariTagTagDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagDetailsResp)
getQolariTagTagDetails merchantShortId opCity apiTokenInfo tagName = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagTagDetails merchantShortId opCity apiTokenInfo tagName

postQolariTagQueryCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueriesAPIEntity -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagQueryCreate merchantShortId opCity apiTokenInfo req

postQolariTagQueryUpdate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryUpdateReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagQueryUpdate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagQueryUpdate merchantShortId opCity apiTokenInfo req

deleteQolariTagQueryDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ChakraQueryDeleteReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagQueryDelete merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.deleteQolariTagQueryDelete merchantShortId opCity apiTokenInfo req

getQolariTagQueryDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueriesAPIEntity)
getQolariTagQueryDetails merchantShortId opCity apiTokenInfo chakra queryName = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagQueryDetails merchantShortId opCity apiTokenInfo chakra queryName

postQolariTagAppDynamicLogicVerify :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.AppDynamicLogicReq -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicResp)
postQolariTagAppDynamicLogicVerify merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagAppDynamicLogicVerify merchantShortId opCity apiTokenInfo req

getQolariTagAppDynamicLogic :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Int -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.GetLogicsResp])
getQolariTagAppDynamicLogic merchantShortId opCity apiTokenInfo version domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogic merchantShortId opCity apiTokenInfo version domain

postQolariTagRunJob :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.RunKaalChakraJobReq -> Environment.FlowHandler Lib.Yudhishthira.Types.RunKaalChakraJobRes)
postQolariTagRunJob merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagRunJob merchantShortId opCity apiTokenInfo req

getQolariTagTimeBounds :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.TimeBoundResp)
getQolariTagTimeBounds merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagTimeBounds merchantShortId opCity apiTokenInfo domain

postQolariTagTimeBoundsCreate :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateTimeBoundRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagTimeBoundsCreate merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagTimeBoundsCreate merchantShortId opCity apiTokenInfo req

deleteQolariTagTimeBoundsDelete :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Kernel.Prelude.Text -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
deleteQolariTagTimeBoundsDelete merchantShortId opCity apiTokenInfo domain name = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.deleteQolariTagTimeBoundsDelete merchantShortId opCity apiTokenInfo domain name

getQolariTagAppDynamicLogicGetLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Prelude.Maybe Kernel.Prelude.Text -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicRolloutObject])
getQolariTagAppDynamicLogicGetLogicRollout merchantShortId opCity apiTokenInfo activeOnly timeBound domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicGetLogicRollout merchantShortId opCity apiTokenInfo activeOnly timeBound domain

postQolariTagAppDynamicLogicUpsertLogicRollout :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicRolloutReq -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagAppDynamicLogicUpsertLogicRollout merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagAppDynamicLogicUpsertLogicRollout merchantShortId opCity apiTokenInfo req

getQolariTagAppDynamicLogicVersions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Int -> Kernel.Prelude.Maybe Kernel.Prelude.Int -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicVersionResp)
getQolariTagAppDynamicLogicVersions merchantShortId opCity apiTokenInfo limit offset domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicVersions merchantShortId opCity apiTokenInfo limit offset domain

getQolariTagAppDynamicLogicDomains :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Environment.FlowHandler Lib.Yudhishthira.Types.AppDynamicLogicDomainResp)
getQolariTagAppDynamicLogicDomains merchantShortId opCity apiTokenInfo = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicDomains merchantShortId opCity apiTokenInfo

getQolariTagAppDynamicLogicDomainsAndEvents :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Environment.FlowHandler Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp)
getQolariTagAppDynamicLogicDomainsAndEvents merchantShortId opCity apiTokenInfo fetchQolariTagNames = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicDomainsAndEvents merchantShortId opCity apiTokenInfo fetchQolariTagNames

getQolariTagAppDynamicLogicGetDomainSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagAppDynamicLogicGetDomainSchema merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagAppDynamicLogicGetDomainSchema merchantShortId opCity apiTokenInfo domain

getQolariTagQueryAll :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.Chakra -> Environment.FlowHandler Lib.Yudhishthira.Types.ChakraQueryResp)
getQolariTagQueryAll merchantShortId opCity apiTokenInfo chakra = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagQueryAll merchantShortId opCity apiTokenInfo chakra

postQolariTagConfigPilotGetVersion :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigGetVersionResponse)
postQolariTagConfigPilotGetVersion merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotGetVersion merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotGetConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.UiConfigResponse)
postQolariTagConfigPilotGetConfig merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotGetConfig merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotCreateUiConfig :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.CreateConfigRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateUiConfig merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotCreateUiConfig merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotAllConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigType])
getQolariTagConfigPilotAllConfigs merchantShortId opCity apiTokenInfo underExperiment = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotAllConfigs merchantShortId opCity apiTokenInfo underExperiment

getQolariTagConfigPilotConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotConfigDetails merchantShortId opCity apiTokenInfo tableName = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotConfigDetails merchantShortId opCity apiTokenInfo tableName

getQolariTagConfigPilotGetTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetTableData merchantShortId opCity apiTokenInfo tableName = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotGetTableData merchantShortId opCity apiTokenInfo tableName

getQolariTagConfigPilotAllUiConfigs :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Environment.FlowHandler [Lib.Yudhishthira.Types.LogicDomain])
getQolariTagConfigPilotAllUiConfigs merchantShortId opCity apiTokenInfo underExperiment = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotAllUiConfigs merchantShortId opCity apiTokenInfo underExperiment

getQolariTagConfigPilotUiConfigDetails :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler [Lib.Yudhishthira.Types.ConfigDetailsResp])
getQolariTagConfigPilotUiConfigDetails merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotUiConfigDetails merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotGetUiTableData :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.UiDevicePlatformReq -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
getQolariTagConfigPilotGetUiTableData merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotGetUiTableData merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotAlwaysOnList :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.LogicDomain -> Environment.FlowHandler Lib.Yudhishthira.Types.AlwaysOnListResp)
getQolariTagConfigPilotAlwaysOnList merchantShortId opCity apiTokenInfo domain = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotAlwaysOnList merchantShortId opCity apiTokenInfo domain

postQolariTagConfigPilotActionChange :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ActionChangeRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotActionChange merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotActionChange merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotGetPatchedElement :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.GetPatchedElementReq -> Environment.FlowHandler Lib.Yudhishthira.Types.GetPatchedElementResp)
postQolariTagConfigPilotGetPatchedElement merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotGetPatchedElement merchantShortId opCity apiTokenInfo req

postQolariTagConfigPilotGetConfigWithDimensions :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest -> Environment.FlowHandler Lib.Yudhishthira.Types.TableDataResp)
postQolariTagConfigPilotGetConfigWithDimensions merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotGetConfigWithDimensions merchantShortId opCity apiTokenInfo req

getQolariTagConfigPilotGetDimensionSchema :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigType -> Environment.FlowHandler Lib.Yudhishthira.Types.DomainSchemaResp)
getQolariTagConfigPilotGetDimensionSchema merchantShortId opCity apiTokenInfo configType = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagConfigPilotGetDimensionSchema merchantShortId opCity apiTokenInfo configType

postQolariTagConfigPilotCreateRow :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest -> Environment.FlowHandler Kernel.Types.APISuccess.APISuccess)
postQolariTagConfigPilotCreateRow merchantShortId opCity apiTokenInfo req = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.postQolariTagConfigPilotCreateRow merchantShortId opCity apiTokenInfo req

getQolariTagBehaviorVisibility :: (Kernel.Types.Id.ShortId Domain.Types.Merchant.Merchant -> Kernel.Types.Beckn.Context.City -> ApiTokenInfo -> Kernel.Prelude.Text -> Kernel.Prelude.Text -> Environment.FlowHandler Lib.BehaviorTracker.Types.EntityBehaviorVisibility)
getQolariTagBehaviorVisibility merchantShortId opCity apiTokenInfo entityType entityId = withFlowHandlerAPI' $ Domain.Action.ProviderPlatform.Management.QolariTag.getQolariTagBehaviorVisibility merchantShortId opCity apiTokenInfo entityType entityId
