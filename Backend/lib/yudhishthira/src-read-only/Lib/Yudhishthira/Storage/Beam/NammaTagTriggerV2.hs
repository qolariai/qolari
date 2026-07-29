{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Beam.QolariTagTriggerV2 where

import qualified Database.Beam as B
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Lib.Yudhishthira.Types
import Tools.Beam.UtilsTH

data QolariTagTriggerV2T f = QolariTagTriggerV2T
  { createdAt :: (B.C f Kernel.Prelude.UTCTime),
    event :: (B.C f Lib.Yudhishthira.Types.ApplicationEvent),
    merchantOperatingCityId :: (B.C f Kernel.Prelude.Text),
    tagName :: (B.C f Kernel.Prelude.Text),
    updatedAt :: (B.C f Kernel.Prelude.UTCTime)
  }
  deriving (Generic, B.Beamable)

instance B.Table QolariTagTriggerV2T where
  data PrimaryKey QolariTagTriggerV2T f = QolariTagTriggerV2Id (B.C f Lib.Yudhishthira.Types.ApplicationEvent) (B.C f Kernel.Prelude.Text) (B.C f Kernel.Prelude.Text) deriving (Generic, B.Beamable)
  primaryKey = QolariTagTriggerV2Id <$> event <*> merchantOperatingCityId <*> tagName

type QolariTagTriggerV2 = QolariTagTriggerV2T Identity

$(enableKVPG (''QolariTagTriggerV2T) [('event), ('merchantOperatingCityId), ('tagName)] [])

$(mkTableInstancesGenericSchema (''QolariTagTriggerV2T) "QOLARI_TAG_trigger_v2")
