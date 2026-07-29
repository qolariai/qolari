-- {"api":"PostQolariTagTagCreate","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG CREATE_QOLARI_TAG","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_TAG_CREATE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'CREATE_QOLARI_TAG' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagTagUpdate","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG CREATE_QOLARI_TAG","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_TAG_UPDATE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'CREATE_QOLARI_TAG' ) ON CONFLICT DO NOTHING;

-- {"api":"DeleteQolariTagTagDelete","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG CREATE_QOLARI_TAG","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/DELETE_QOLARI_TAG_TAG_DELETE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'CREATE_QOLARI_TAG' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagQueryCreate","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG CREATE_CHAKRA_QUERY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_QUERY_CREATE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'CREATE_CHAKRA_QUERY' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagAppDynamicLogicVerify","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERIFY' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagAppDynamicLogic","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_APP_DYNAMIC_LOGIC' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagRunJob","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG RUN_KAAL_CHAKRA_JOB","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_RUN_JOB' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'RUN_KAAL_CHAKRA_JOB' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagTimeBounds","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG TIME_BOUNDS","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_TIME_BOUNDS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'TIME_BOUNDS' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagTimeBoundsCreate","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG TIME_BOUNDS","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_TIME_BOUNDS_CREATE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'TIME_BOUNDS' ) ON CONFLICT DO NOTHING;

-- {"api":"DeleteQolariTagTimeBoundsDelete","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG TIME_BOUNDS","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/DELETE_QOLARI_TAG_TIME_BOUNDS_DELETE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'TIME_BOUNDS' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagAppDynamicLogicGetLogicRollout","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_ROLLOUT","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_GET_LOGIC_ROLLOUT' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_ROLLOUT' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagAppDynamicLogicUpsertLogicRollout","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_ROLLOUT","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_APP_DYNAMIC_LOGIC_UPSERT_LOGIC_ROLLOUT' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_ROLLOUT' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagAppDynamicLogicVersions","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_VERSIONS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagAppDynamicLogicDomains","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_APP_DYNAMIC_LOGIC_DOMAINS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagQueryAll","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG GET_CHAKRA_QUERY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_QUERY_ALL' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'GET_CHAKRA_QUERY' ) ON CONFLICT DO NOTHING;


------- SQL updates -------

-- {"api":"PostQolariTagUpdateCustomerTag","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG MANUAL_TAG_UPDATE","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_UPDATE_CUSTOMER_TAG' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'MANUAL_TAG_UPDATE' ) ON CONFLICT DO NOTHING;


------- SQL updates -------

-- {"api":"PostQolariTagConfigPilotGetVersion","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG POST_RETRIEVE_VERSION","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_GET_VERSION' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'POST_RETRIEVE_VERSION' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagConfigPilotGetConfig","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG POST_RETRIEVE_CONFIG","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_GET_CONFIG' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'POST_RETRIEVE_CONFIG' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagConfigPilotCreateUiConfig","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG CREATE_UI_CONFIG","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_CREATE_UI_CONFIG' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'CREATE_UI_CONFIG' ) ON CONFLICT DO NOTHING;


------- SQL updates -------

-- {"api":"GetQolariTagConfigPilotAllConfigs","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_ALL_CONFIGS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagConfigPilotConfigDetails","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_CONFIG_DETAILS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagConfigPilotGetTableData","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_GET_TABLE_DATA' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;


------- SQL updates -------

-- {"api":"PostQolariTagConfigPilotActionChange","migration":"endpointV2","param":null,"schema":"atlas_bap_dashboard"}
UPDATE atlas_bap_dashboard.transaction
  SET endpoint = 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE'
  WHERE endpoint = 'QolariTagAPI PostQolariTagConfigPilotActionChangeEndpoint';

-- {"api":"PostQolariTagConfigPilotActionChange","migration":"userActionType","param":"ApiAuth DRIVER_OFFER_BPP_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;


------- SQL updates -------

-- {"api":"GetQolariTagConfigPilotAllUiConfigs","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_ALL_UI_CONFIGS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagConfigPilotUiConfigDetails","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_UI_CONFIG_DETAILS' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"GetQolariTagConfigPilotGetUiTableData","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/GET_QOLARI_TAG_CONFIG_PILOT_GET_UI_TABLE_DATA' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;

-- {"api":"PostQolariTagConfigPilotActionChange","migration":"userActionType","param":"ApiAuth APP_BACKEND_MANAGEMENT QOLARI_TAG APP_DYNAMIC_LOGIC_VERIFY","schema":"atlas_bap_dashboard"}
INSERT INTO atlas_bap_dashboard.access_matrix (id, role_id, api_entity, user_access_type, user_action_type) ( SELECT atlas_bap_dashboard.uuid_generate_v4(), T1.role_id, 'DSL', 'USER_FULL_ACCESS', 'RIDER_MANAGEMENT/QOLARI_TAG/POST_QOLARI_TAG_CONFIG_PILOT_ACTION_CHANGE' FROM atlas_bap_dashboard.access_matrix AS T1 WHERE T1.user_access_type = 'USER_FULL_ACCESS' AND T1.api_entity = 'QOLARI_TAG' AND T1.user_action_type = 'APP_DYNAMIC_LOGIC_VERIFY' ) ON CONFLICT DO NOTHING;
