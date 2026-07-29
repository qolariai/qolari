{-# LANGUAGE ApplicativeDo #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Types.QolariTagTrigger where

import Data.Aeson
import Kernel.Prelude
import qualified Lib.Yudhishthira.Types
import qualified Tools.Beam.UtilsTH

data QolariTagTrigger = QolariTagTrigger {createdAt :: Kernel.Prelude.UTCTime, event :: Lib.Yudhishthira.Types.ApplicationEvent, tagName :: Kernel.Prelude.Text, updatedAt :: Kernel.Prelude.UTCTime}
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema)
