{-# LANGUAGE ApplicativeDo #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Types.QolariTagTriggerV2 where

import Data.Aeson
import Kernel.Prelude
import qualified Kernel.Types.Id
import qualified Lib.Yudhishthira.Types
import qualified Tools.Beam.UtilsTH

data QolariTagTriggerV2 = QolariTagTriggerV2
  { createdAt :: Kernel.Prelude.UTCTime,
    event :: Lib.Yudhishthira.Types.ApplicationEvent,
    merchantOperatingCityId :: Kernel.Types.Id.Id Lib.Yudhishthira.Types.MerchantOperatingCity,
    tagName :: Kernel.Prelude.Text,
    updatedAt :: Kernel.Prelude.UTCTime
  }
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema)
