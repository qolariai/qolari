{-# LANGUAGE StandaloneKindSignatures #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module API.Types.ProviderPlatform.Management.Endpoints.QolariTag where

import Data.OpenApi (ToSchema)
import qualified Data.Singletons.TH
import EulerHS.Prelude hiding (id, state)
import qualified EulerHS.Types
import qualified Kernel.Prelude
import qualified Kernel.Types.APISuccess
import Kernel.Types.Common
import qualified Lib.BehaviorTracker.Types
import qualified Lib.Yudhishthira.Types
import Servant
import Servant.Client

type API = ("QolariTag" :> (PostQolariTagTagCreate :<|> PostQolariTagTagVerify :<|> PostQolariTagTagUpdate :<|> DeleteQolariTagTagDelete :<|> GetQolariTagTagAll :<|> GetQolariTagTagDetails :<|> PostQolariTagQueryCreate :<|> PostQolariTagQueryUpdate :<|> DeleteQolariTagQueryDelete :<|> GetQolariTagQueryDetails :<|> PostQolariTagAppDynamicLogicVerify :<|> GetQolariTagAppDynamicLogic :<|> PostQolariTagRunJob :<|> GetQolariTagTimeBounds :<|> PostQolariTagTimeBoundsCreate :<|> DeleteQolariTagTimeBoundsDelete :<|> GetQolariTagAppDynamicLogicGetLogicRollout :<|> PostQolariTagAppDynamicLogicUpsertLogicRollout :<|> GetQolariTagAppDynamicLogicVersions :<|> GetQolariTagAppDynamicLogicDomains :<|> GetQolariTagAppDynamicLogicDomainsAndEvents :<|> GetQolariTagAppDynamicLogicGetDomainSchema :<|> GetQolariTagQueryAll :<|> PostQolariTagConfigPilotGetVersion :<|> PostQolariTagConfigPilotGetConfig :<|> PostQolariTagConfigPilotCreateUiConfig :<|> GetQolariTagConfigPilotAllConfigs :<|> GetQolariTagConfigPilotConfigDetails :<|> GetQolariTagConfigPilotGetTableData :<|> GetQolariTagConfigPilotAllUiConfigs :<|> GetQolariTagConfigPilotUiConfigDetails :<|> GetQolariTagConfigPilotGetUiTableData :<|> GetQolariTagConfigPilotAlwaysOnList :<|> PostQolariTagConfigPilotActionChange :<|> PostQolariTagConfigPilotGetPatchedElement :<|> PostQolariTagConfigPilotGetConfigWithDimensions :<|> GetQolariTagConfigPilotGetDimensionSchema :<|> PostQolariTagConfigPilotCreateRow :<|> GetQolariTagBehaviorVisibility))

type PostQolariTagTagCreate = ("tag" :> "create" :> ReqBody '[JSON] Lib.Yudhishthira.Types.CreateQolariTagRequest :> Post '[JSON] Lib.Yudhishthira.Types.CreateQolariTagResponse)

type PostQolariTagTagVerify = ("tag" :> "verify" :> ReqBody '[JSON] Lib.Yudhishthira.Types.VerifyQolariTagRequest :> Post '[JSON] Lib.Yudhishthira.Types.VerifyQolariTagResponse)

type PostQolariTagTagUpdate = ("tag" :> "update" :> ReqBody '[JSON] Lib.Yudhishthira.Types.UpdateQolariTagRequest :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type DeleteQolariTagTagDelete = ("tag" :> "delete" :> MandatoryQueryParam "tagName" Kernel.Prelude.Text :> Delete '[JSON] Kernel.Types.APISuccess.APISuccess)

type GetQolariTagTagAll = ("tag" :> "all" :> Get '[JSON] [Lib.Yudhishthira.Types.QolariTagDetailsResp])

type GetQolariTagTagDetails = ("tag" :> "details" :> MandatoryQueryParam "tagName" Kernel.Prelude.Text :> Get '[JSON] Lib.Yudhishthira.Types.QolariTagDetailsResp)

type PostQolariTagQueryCreate = ("query" :> "create" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ChakraQueriesAPIEntity :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type PostQolariTagQueryUpdate = ("query" :> "update" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ChakraQueryUpdateReq :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type DeleteQolariTagQueryDelete = ("query" :> "delete" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ChakraQueryDeleteReq :> Delete '[JSON] Kernel.Types.APISuccess.APISuccess)

type GetQolariTagQueryDetails =
  ( "query" :> "details" :> MandatoryQueryParam "chakra" Lib.Yudhishthira.Types.Chakra :> MandatoryQueryParam "queryName" Kernel.Prelude.Text
      :> Get
           '[JSON]
           Lib.Yudhishthira.Types.ChakraQueriesAPIEntity
  )

type PostQolariTagAppDynamicLogicVerify = ("appDynamicLogic" :> "verify" :> ReqBody '[JSON] Lib.Yudhishthira.Types.AppDynamicLogicReq :> Post '[JSON] Lib.Yudhishthira.Types.AppDynamicLogicResp)

type GetQolariTagAppDynamicLogic =
  ( "appDynamicLogic" :> QueryParam "version" Kernel.Prelude.Int :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain
      :> Get
           '[JSON]
           [Lib.Yudhishthira.Types.GetLogicsResp]
  )

type PostQolariTagRunJob = ("runJob" :> ReqBody '[JSON] Lib.Yudhishthira.Types.RunKaalChakraJobReq :> Post '[JSON] Lib.Yudhishthira.Types.RunKaalChakraJobRes)

type GetQolariTagTimeBounds = ("timeBounds" :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain :> Get '[JSON] Lib.Yudhishthira.Types.TimeBoundResp)

type PostQolariTagTimeBoundsCreate = ("timeBounds" :> "create" :> ReqBody '[JSON] Lib.Yudhishthira.Types.CreateTimeBoundRequest :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type DeleteQolariTagTimeBoundsDelete =
  ( "timeBounds" :> "delete" :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain :> MandatoryQueryParam "name" Kernel.Prelude.Text
      :> Delete
           '[JSON]
           Kernel.Types.APISuccess.APISuccess
  )

type GetQolariTagAppDynamicLogicGetLogicRollout =
  ( "appDynamicLogic" :> "getLogicRollout" :> QueryParam "activeOnly" Kernel.Prelude.Bool
      :> QueryParam
           "timeBound"
           Kernel.Prelude.Text
      :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain
      :> Get '[JSON] [Lib.Yudhishthira.Types.LogicRolloutObject]
  )

type PostQolariTagAppDynamicLogicUpsertLogicRollout =
  ( "appDynamicLogic" :> "upsertLogicRollout" :> ReqBody '[JSON] Lib.Yudhishthira.Types.LogicRolloutReq
      :> Post
           '[JSON]
           Kernel.Types.APISuccess.APISuccess
  )

type GetQolariTagAppDynamicLogicVersions =
  ( "appDynamicLogic" :> "versions" :> QueryParam "limit" Kernel.Prelude.Int :> QueryParam "offset" Kernel.Prelude.Int
      :> MandatoryQueryParam
           "domain"
           Lib.Yudhishthira.Types.LogicDomain
      :> Get '[JSON] Lib.Yudhishthira.Types.AppDynamicLogicVersionResp
  )

type GetQolariTagAppDynamicLogicDomains = ("appDynamicLogic" :> "domains" :> Get '[JSON] Lib.Yudhishthira.Types.AppDynamicLogicDomainResp)

type GetQolariTagAppDynamicLogicDomainsAndEvents =
  ( "appDynamicLogic" :> "domainsAndEvents" :> QueryParam "fetchQolariTagNames" Kernel.Prelude.Bool
      :> Get
           '[JSON]
           Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp
  )

type GetQolariTagAppDynamicLogicGetDomainSchema =
  ( "appDynamicLogic" :> "getDomainSchema" :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain
      :> Get
           '[JSON]
           Lib.Yudhishthira.Types.DomainSchemaResp
  )

type GetQolariTagQueryAll = ("query" :> "all" :> MandatoryQueryParam "chakra" Lib.Yudhishthira.Types.Chakra :> Get '[JSON] Lib.Yudhishthira.Types.ChakraQueryResp)

type PostQolariTagConfigPilotGetVersion = ("configPilot" :> "getVersion" :> ReqBody '[JSON] Lib.Yudhishthira.Types.UiConfigRequest :> Post '[JSON] Lib.Yudhishthira.Types.UiConfigGetVersionResponse)

type PostQolariTagConfigPilotGetConfig = ("configPilot" :> "getConfig" :> ReqBody '[JSON] Lib.Yudhishthira.Types.UiConfigRequest :> Post '[JSON] Lib.Yudhishthira.Types.UiConfigResponse)

type PostQolariTagConfigPilotCreateUiConfig = ("configPilot" :> "createUiConfig" :> ReqBody '[JSON] Lib.Yudhishthira.Types.CreateConfigRequest :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type GetQolariTagConfigPilotAllConfigs = ("configPilot" :> "allConfigs" :> QueryParam "underExperiment" Kernel.Prelude.Bool :> Get '[JSON] [Lib.Yudhishthira.Types.ConfigType])

type GetQolariTagConfigPilotConfigDetails =
  ( "configPilot" :> "configDetails" :> MandatoryQueryParam "tableName" Lib.Yudhishthira.Types.ConfigType
      :> Get
           '[JSON]
           [Lib.Yudhishthira.Types.ConfigDetailsResp]
  )

type GetQolariTagConfigPilotGetTableData = ("configPilot" :> "getTableData" :> MandatoryQueryParam "tableName" Lib.Yudhishthira.Types.ConfigType :> Get '[JSON] Lib.Yudhishthira.Types.TableDataResp)

type GetQolariTagConfigPilotAllUiConfigs = ("configPilot" :> "allUiConfigs" :> QueryParam "underExperiment" Kernel.Prelude.Bool :> Get '[JSON] [Lib.Yudhishthira.Types.LogicDomain])

type GetQolariTagConfigPilotUiConfigDetails =
  ( "configPilot" :> "uiConfigDetails" :> ReqBody '[JSON] Lib.Yudhishthira.Types.UiDevicePlatformReq
      :> Get
           '[JSON]
           [Lib.Yudhishthira.Types.ConfigDetailsResp]
  )

type GetQolariTagConfigPilotGetUiTableData = ("configPilot" :> "getUiTableData" :> ReqBody '[JSON] Lib.Yudhishthira.Types.UiDevicePlatformReq :> Get '[JSON] Lib.Yudhishthira.Types.TableDataResp)

type GetQolariTagConfigPilotAlwaysOnList = ("configPilot" :> "alwaysOnList" :> MandatoryQueryParam "domain" Lib.Yudhishthira.Types.LogicDomain :> Get '[JSON] Lib.Yudhishthira.Types.AlwaysOnListResp)

type PostQolariTagConfigPilotActionChange = ("configPilot" :> "actionChange" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ActionChangeRequest :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type PostQolariTagConfigPilotGetPatchedElement =
  ( "configPilot" :> "getPatchedElement" :> ReqBody '[JSON] Lib.Yudhishthira.Types.GetPatchedElementReq
      :> Post
           '[JSON]
           Lib.Yudhishthira.Types.GetPatchedElementResp
  )

type PostQolariTagConfigPilotGetConfigWithDimensions =
  ( "configPilot" :> "getConfigWithDimensions" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest
      :> Post
           '[JSON]
           Lib.Yudhishthira.Types.TableDataResp
  )

type GetQolariTagConfigPilotGetDimensionSchema =
  ( "configPilot" :> "getDimensionSchema" :> MandatoryQueryParam "configType" Lib.Yudhishthira.Types.ConfigType
      :> Get
           '[JSON]
           Lib.Yudhishthira.Types.DomainSchemaResp
  )

type PostQolariTagConfigPilotCreateRow = ("configPilot" :> "createRow" :> ReqBody '[JSON] Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest :> Post '[JSON] Kernel.Types.APISuccess.APISuccess)

type GetQolariTagBehaviorVisibility =
  ( "behaviorVisibility" :> Capture "entityType" Kernel.Prelude.Text :> Capture "entityId" Kernel.Prelude.Text
      :> Get
           '[JSON]
           Lib.BehaviorTracker.Types.EntityBehaviorVisibility
  )

data QolariTagAPIs = QolariTagAPIs
  { postQolariTagTagCreate :: Lib.Yudhishthira.Types.CreateQolariTagRequest -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.CreateQolariTagResponse,
    postQolariTagTagVerify :: Lib.Yudhishthira.Types.VerifyQolariTagRequest -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.VerifyQolariTagResponse,
    postQolariTagTagUpdate :: Lib.Yudhishthira.Types.UpdateQolariTagRequest -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    deleteQolariTagTagDelete :: Kernel.Prelude.Text -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagTagAll :: EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.QolariTagDetailsResp],
    getQolariTagTagDetails :: Kernel.Prelude.Text -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.QolariTagDetailsResp,
    postQolariTagQueryCreate :: Lib.Yudhishthira.Types.ChakraQueriesAPIEntity -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    postQolariTagQueryUpdate :: Lib.Yudhishthira.Types.ChakraQueryUpdateReq -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    deleteQolariTagQueryDelete :: Lib.Yudhishthira.Types.ChakraQueryDeleteReq -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagQueryDetails :: Lib.Yudhishthira.Types.Chakra -> Kernel.Prelude.Text -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.ChakraQueriesAPIEntity,
    postQolariTagAppDynamicLogicVerify :: Lib.Yudhishthira.Types.AppDynamicLogicReq -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.AppDynamicLogicResp,
    getQolariTagAppDynamicLogic :: Kernel.Prelude.Maybe Kernel.Prelude.Int -> Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.GetLogicsResp],
    postQolariTagRunJob :: Lib.Yudhishthira.Types.RunKaalChakraJobReq -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.RunKaalChakraJobRes,
    getQolariTagTimeBounds :: Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.TimeBoundResp,
    postQolariTagTimeBoundsCreate :: Lib.Yudhishthira.Types.CreateTimeBoundRequest -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    deleteQolariTagTimeBoundsDelete :: Lib.Yudhishthira.Types.LogicDomain -> Kernel.Prelude.Text -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagAppDynamicLogicGetLogicRollout :: Kernel.Prelude.Maybe Kernel.Prelude.Bool -> Kernel.Prelude.Maybe Kernel.Prelude.Text -> Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.LogicRolloutObject],
    postQolariTagAppDynamicLogicUpsertLogicRollout :: Lib.Yudhishthira.Types.LogicRolloutReq -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagAppDynamicLogicVersions :: Kernel.Prelude.Maybe Kernel.Prelude.Int -> Kernel.Prelude.Maybe Kernel.Prelude.Int -> Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.AppDynamicLogicVersionResp,
    getQolariTagAppDynamicLogicDomains :: EulerHS.Types.EulerClient Lib.Yudhishthira.Types.AppDynamicLogicDomainResp,
    getQolariTagAppDynamicLogicDomainsAndEvents :: Kernel.Prelude.Maybe Kernel.Prelude.Bool -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.QolariTagEventsOrQolariTagNamesResp,
    getQolariTagAppDynamicLogicGetDomainSchema :: Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.DomainSchemaResp,
    getQolariTagQueryAll :: Lib.Yudhishthira.Types.Chakra -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.ChakraQueryResp,
    postQolariTagConfigPilotGetVersion :: Lib.Yudhishthira.Types.UiConfigRequest -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.UiConfigGetVersionResponse,
    postQolariTagConfigPilotGetConfig :: Lib.Yudhishthira.Types.UiConfigRequest -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.UiConfigResponse,
    postQolariTagConfigPilotCreateUiConfig :: Lib.Yudhishthira.Types.CreateConfigRequest -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagConfigPilotAllConfigs :: Kernel.Prelude.Maybe Kernel.Prelude.Bool -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.ConfigType],
    getQolariTagConfigPilotConfigDetails :: Lib.Yudhishthira.Types.ConfigType -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.ConfigDetailsResp],
    getQolariTagConfigPilotGetTableData :: Lib.Yudhishthira.Types.ConfigType -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.TableDataResp,
    getQolariTagConfigPilotAllUiConfigs :: Kernel.Prelude.Maybe Kernel.Prelude.Bool -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.LogicDomain],
    getQolariTagConfigPilotUiConfigDetails :: Lib.Yudhishthira.Types.UiDevicePlatformReq -> EulerHS.Types.EulerClient [Lib.Yudhishthira.Types.ConfigDetailsResp],
    getQolariTagConfigPilotGetUiTableData :: Lib.Yudhishthira.Types.UiDevicePlatformReq -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.TableDataResp,
    getQolariTagConfigPilotAlwaysOnList :: Lib.Yudhishthira.Types.LogicDomain -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.AlwaysOnListResp,
    postQolariTagConfigPilotActionChange :: Lib.Yudhishthira.Types.ActionChangeRequest -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    postQolariTagConfigPilotGetPatchedElement :: Lib.Yudhishthira.Types.GetPatchedElementReq -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.GetPatchedElementResp,
    postQolariTagConfigPilotGetConfigWithDimensions :: Lib.Yudhishthira.Types.ConfigPilotGetConfigRequest -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.TableDataResp,
    getQolariTagConfigPilotGetDimensionSchema :: Lib.Yudhishthira.Types.ConfigType -> EulerHS.Types.EulerClient Lib.Yudhishthira.Types.DomainSchemaResp,
    postQolariTagConfigPilotCreateRow :: Lib.Yudhishthira.Types.ConfigPilotCreateRowRequest -> EulerHS.Types.EulerClient Kernel.Types.APISuccess.APISuccess,
    getQolariTagBehaviorVisibility :: Kernel.Prelude.Text -> Kernel.Prelude.Text -> EulerHS.Types.EulerClient Lib.BehaviorTracker.Types.EntityBehaviorVisibility
  }

mkQolariTagAPIs :: (Client EulerHS.Types.EulerClient API -> QolariTagAPIs)
mkQolariTagAPIs QolariTagClient = (QolariTagAPIs {..})
  where
    postQolariTagTagCreate :<|> postQolariTagTagVerify :<|> postQolariTagTagUpdate :<|> deleteQolariTagTagDelete :<|> getQolariTagTagAll :<|> getQolariTagTagDetails :<|> postQolariTagQueryCreate :<|> postQolariTagQueryUpdate :<|> deleteQolariTagQueryDelete :<|> getQolariTagQueryDetails :<|> postQolariTagAppDynamicLogicVerify :<|> getQolariTagAppDynamicLogic :<|> postQolariTagRunJob :<|> getQolariTagTimeBounds :<|> postQolariTagTimeBoundsCreate :<|> deleteQolariTagTimeBoundsDelete :<|> getQolariTagAppDynamicLogicGetLogicRollout :<|> postQolariTagAppDynamicLogicUpsertLogicRollout :<|> getQolariTagAppDynamicLogicVersions :<|> getQolariTagAppDynamicLogicDomains :<|> getQolariTagAppDynamicLogicDomainsAndEvents :<|> getQolariTagAppDynamicLogicGetDomainSchema :<|> getQolariTagQueryAll :<|> postQolariTagConfigPilotGetVersion :<|> postQolariTagConfigPilotGetConfig :<|> postQolariTagConfigPilotCreateUiConfig :<|> getQolariTagConfigPilotAllConfigs :<|> getQolariTagConfigPilotConfigDetails :<|> getQolariTagConfigPilotGetTableData :<|> getQolariTagConfigPilotAllUiConfigs :<|> getQolariTagConfigPilotUiConfigDetails :<|> getQolariTagConfigPilotGetUiTableData :<|> getQolariTagConfigPilotAlwaysOnList :<|> postQolariTagConfigPilotActionChange :<|> postQolariTagConfigPilotGetPatchedElement :<|> postQolariTagConfigPilotGetConfigWithDimensions :<|> getQolariTagConfigPilotGetDimensionSchema :<|> postQolariTagConfigPilotCreateRow :<|> getQolariTagBehaviorVisibility = QolariTagClient

data QolariTagUserActionType
  = POST_QOLARI_TAG_TAG_CREATE
  | POST_QOLARI_TAG_TAG_VERIFY
  | POST_QOLARI_TAG_TAG_UPDATE
  | DELETE_QOLARI_TAG_TAG_DELETE
  | GET_QOLARI_TAG_TAG_ALL
  | GET_QOLARI_TAG_TAG_DETAILS
  | POST_QOLARI_TAG_QUERY_CREATE
  | POST_QOLARI_TAG_QUERY_UPDATE
  | DELETE_QOLARI_TAG_QUERY_DELETE
  | GET_QOLARI_TAG_QUERY_DETAILS
  | POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERIFY
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC
  | POST_QOLARI_TAG_RUN_JOB
  | GET_QOLARI_TAG_TIME_BOUNDS
  | POST_QOLARI_TAG_TIME_BOUNDS_CREATE
  | DELETE_QOLARI_TAG_TIME_BOUNDS_DELETE
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_LOGIC_ROLLOUT
  | POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_UPSERT_LOGIC_ROLLOUT
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERSIONS
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS_AND_EVENTS
  | GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_DOMAIN_SCHEMA
  | GET_QOLARI_TAG_QUERY_ALL
  | POST_QOLARI_TAG_CONFIG_PILOT_GET_VERSION
  | POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG
  | POST_QOLARI_TAG_CONFIG_PILOT_CREATE_UI_CONFIG
  | GET_QOLARI_TAG_CONFIG_PILOT_ALL_CONFIGS
  | GET_QOLARI_TAG_CONFIG_PILOT_CONFIG_DETAILS
  | GET_QOLARI_TAG_CONFIG_PILOT_GET_TABLE_DATA
  | GET_QOLARI_TAG_CONFIG_PILOT_ALL_UI_CONFIGS
  | GET_QOLARI_TAG_CONFIG_PILOT_UI_CONFIG_DETAILS
  | GET_QOLARI_TAG_CONFIG_PILOT_GET_UI_TABLE_DATA
  | GET_QOLARI_TAG_CONFIG_PILOT_ALWAYS_ON_LIST
  | POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE
  | POST_QOLARI_TAG_CONFIG_PILOT_GET_PATCHED_ELEMENT
  | POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG_WITH_DIMENSIONS
  | GET_QOLARI_TAG_CONFIG_PILOT_GET_DIMENSION_SCHEMA
  | POST_QOLARI_TAG_CONFIG_PILOT_CREATE_ROW
  | GET_QOLARI_TAG_BEHAVIOR_VISIBILITY
  deriving stock (Show, Read, Generic, Eq, Ord)
  deriving anyclass (ToJSON, FromJSON, ToSchema)

$(Data.Singletons.TH.genSingletons [''QolariTagUserActionType])
