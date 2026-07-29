{-# LANGUAGE StandaloneDeriving #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Beam.QolariTagV2 where

import qualified Data.Aeson
import qualified Database.Beam as B
import Kernel.External.Encryption
import Kernel.Prelude
import qualified Kernel.Prelude
import qualified Kernel.Types.Common
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTagV2
import Tools.Beam.UtilsTH

data QolariTagV2T f = QolariTagV2T
  { actionEngine :: (B.C f (Kernel.Prelude.Maybe Data.Aeson.Value)),
    category :: (B.C f Kernel.Prelude.Text),
    description :: (B.C f (Kernel.Prelude.Maybe Kernel.Prelude.Text)),
    chakra :: (B.C f (Kernel.Prelude.Maybe Lib.Yudhishthira.Types.Chakra)),
    tagType :: (B.C f Lib.Yudhishthira.Types.QolariTagV2.TagType),
    merchantOperatingCityId :: (B.C f Kernel.Prelude.Text),
    name :: (B.C f Kernel.Prelude.Text),
    rangeEnd :: (B.C f (Kernel.Prelude.Maybe Kernel.Prelude.Double)),
    rangeStart :: (B.C f (Kernel.Prelude.Maybe Kernel.Prelude.Double)),
    tags :: (B.C f (Kernel.Prelude.Maybe [Kernel.Prelude.Text])),
    llmContext :: (B.C f (Kernel.Prelude.Maybe Kernel.Prelude.Text)),
    ruleEngine :: (B.C f (Kernel.Prelude.Maybe Data.Aeson.Value)),
    validity :: (B.C f (Kernel.Prelude.Maybe Kernel.Types.Common.Hours)),
    createdAt :: (B.C f Kernel.Prelude.UTCTime),
    updatedAt :: (B.C f Kernel.Prelude.UTCTime)
  }
  deriving (Generic, B.Beamable)

instance B.Table QolariTagV2T where
  data PrimaryKey QolariTagV2T f = QolariTagV2Id (B.C f Kernel.Prelude.Text) (B.C f Kernel.Prelude.Text) deriving (Generic, B.Beamable)
  primaryKey = QolariTagV2Id <$> merchantOperatingCityId <*> name

type QolariTagV2 = QolariTagV2T Identity

$(enableKVPG (''QolariTagV2T) [('merchantOperatingCityId), ('name)] [])

$(mkTableInstancesGenericSchema (''QolariTagV2T) "QOLARI_TAG_v2")
