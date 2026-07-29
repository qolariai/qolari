{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Beam.QolariTagTrigger where

import qualified Database.Beam as B
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Lib.Yudhishthira.Types
import Tools.Beam.UtilsTH

data QolariTagTriggerT f = QolariTagTriggerT
  { createdAt :: (B.C f Kernel.Prelude.UTCTime),
    event :: (B.C f Lib.Yudhishthira.Types.ApplicationEvent),
    tagName :: (B.C f Kernel.Prelude.Text),
    updatedAt :: (B.C f Kernel.Prelude.UTCTime)
  }
  deriving (Generic, B.Beamable)

instance B.Table QolariTagTriggerT where
  data PrimaryKey QolariTagTriggerT f = QolariTagTriggerId (B.C f Lib.Yudhishthira.Types.ApplicationEvent) (B.C f Kernel.Prelude.Text) deriving (Generic, B.Beamable)
  primaryKey = QolariTagTriggerId <$> event <*> tagName

type QolariTagTrigger = QolariTagTriggerT Identity

$(enableKVPG (''QolariTagTriggerT) [('event), ('tagName)] [])

$(mkTableInstancesGenericSchema (''QolariTagTriggerT) "QOLARI_TAG_trigger")
