{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Queries.QolariTagTriggerV2 where

import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Lib.Yudhishthira.Storage.Beam.BeamFlow
import qualified Lib.Yudhishthira.Storage.Beam.QolariTagTriggerV2 as Beam
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTagTriggerV2
import qualified Sequelize as Se

create :: (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) => (Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 -> m ())
create = createWithKV

createMany :: (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) => ([Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2] -> m ())
createMany = traverse_ create

deleteAllByMerchantOperatingCityIdAndTagName ::
  (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) =>
  (Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity -> Kernel.Prelude.Text -> m ())
deleteAllByMerchantOperatingCityIdAndTagName merchantOperatingCityId tagName = do
  deleteWithKV
    [ Se.And
        [ Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId),
          Se.Is Beam.tagName $ Se.Eq tagName
        ]
    ]

findAllByMerchantOperatingCityId ::
  (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) =>
  (Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity -> m ([Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2]))
findAllByMerchantOperatingCityId merchantOperatingCityId = do findAllWithKV [Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId)]

findAllByMerchantOperatingCityIdAndEvent ::
  (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) =>
  (Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity -> Lib.Yudhishthira.Types.ApplicationEvent -> m ([Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2]))
findAllByMerchantOperatingCityIdAndEvent merchantOperatingCityId event = do
  findAllWithKV
    [ Se.And
        [ Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId),
          Se.Is Beam.event $ Se.Eq event
        ]
    ]

findAllByMerchantOperatingCityIdAndTagName ::
  (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) =>
  (Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity -> Kernel.Prelude.Text -> m ([Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2]))
findAllByMerchantOperatingCityIdAndTagName merchantOperatingCityId tagName = do
  findAllWithKV
    [ Se.And
        [ Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId),
          Se.Is Beam.tagName $ Se.Eq tagName
        ]
    ]

findByPrimaryKey ::
  (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) =>
  (Lib.Yudhishthira.Types.ApplicationEvent -> Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity -> Kernel.Prelude.Text -> m (Maybe Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2))
findByPrimaryKey event merchantOperatingCityId tagName = do
  findOneWithKV
    [ Se.And
        [ Se.Is Beam.event $ Se.Eq event,
          Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId),
          Se.Is Beam.tagName $ Se.Eq tagName
        ]
    ]

updateByPrimaryKey :: (Lib.Yudhishthira.Storage.Beam.BeamFlow.BeamFlow m r) => (Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 -> m ())
updateByPrimaryKey (Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 {..}) = do
  _now <- getCurrentTime
  updateWithKV
    [Se.Set Beam.updatedAt _now]
    [ Se.And
        [ Se.Is Beam.event $ Se.Eq event,
          Se.Is Beam.merchantOperatingCityId $ Se.Eq (Kernel.Types.Id.getId merchantOperatingCityId),
          Se.Is Beam.tagName $ Se.Eq tagName
        ]
    ]

instance FromTType' Beam.QolariTagTriggerV2 Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 where
  fromTType' (Beam.QolariTagTriggerV2T {..}) = do
    pure $
      Just
        Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2
          { createdAt = createdAt,
            event = event,
            merchantOperatingCityId = Kernel.Types.Id.Id merchantOperatingCityId,
            tagName = tagName,
            updatedAt = updatedAt
          }

instance ToTType' Beam.QolariTagTriggerV2 Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 where
  toTType' (Lib.Yudhishthira.Types.QolariTagTriggerV2.QolariTagTriggerV2 {..}) = do
    Beam.QolariTagTriggerV2T
      { Beam.createdAt = createdAt,
        Beam.event = event,
        Beam.merchantOperatingCityId = Kernel.Types.Id.getId merchantOperatingCityId,
        Beam.tagName = tagName,
        Beam.updatedAt = updatedAt
      }
