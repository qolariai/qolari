{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Queries.OrphanInstances.QolariTag where

import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import Kernel.Types.Error
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Lib.Yudhishthira.Storage.Beam.QolariTag as Beam
import Lib.Yudhishthira.Storage.Queries.Transformers.QolariTag
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTag

instance FromTType' Beam.QolariTag Lib.Yudhishthira.Types.QolariTag.QolariTag where
  fromTType' (Beam.QolariTagT {..}) = do
    pure $
      Just
        Lib.Yudhishthira.Types.QolariTag.QolariTag
          { actionEngine = actionEngine,
            category = category,
            description = description,
            info = mkTagInfo chakra tagType,
            name = name,
            possibleValues = mkTagValues rangeEnd rangeStart tags,
            rule = mkTagRule llmContext ruleEngine,
            validity = validity,
            createdAt = createdAt,
            updatedAt = updatedAt
          }

instance ToTType' Beam.QolariTag Lib.Yudhishthira.Types.QolariTag.QolariTag where
  toTType' (Lib.Yudhishthira.Types.QolariTag.QolariTag {..}) = do
    Beam.QolariTagT
      { Beam.actionEngine = actionEngine,
        Beam.category = category,
        Beam.description = description,
        Beam.chakra = getChakra info,
        Beam.tagType = getTag info,
        Beam.name = name,
        Beam.rangeEnd = getRangeEnd possibleValues,
        Beam.rangeStart = getRangeStart possibleValues,
        Beam.tags = getTags possibleValues,
        Beam.llmContext = getLlmContext rule,
        Beam.ruleEngine = getRuleEngine rule,
        Beam.validity = validity,
        Beam.createdAt = createdAt,
        Beam.updatedAt = updatedAt
      }
