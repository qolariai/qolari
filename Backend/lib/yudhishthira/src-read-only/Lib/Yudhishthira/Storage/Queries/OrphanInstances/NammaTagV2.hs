{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Lib.Yudhishthira.Storage.Queries.OrphanInstances.QolariTagV2 where

import Kernel.Beam.Functions
import Kernel.External.Encryption
import Kernel.Prelude
import Kernel.Types.Error
import qualified Kernel.Types.Id
import Kernel.Utils.Common (CacheFlow, EsqDBFlow, MonadFlow, fromMaybeM, getCurrentTime)
import qualified Lib.Yudhishthira.Storage.Beam.QolariTagV2 as Beam
import Lib.Yudhishthira.Storage.Queries.Transformers.QolariTagV2
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTagV2

instance FromTType' Beam.QolariTagV2 Lib.Yudhishthira.Types.QolariTagV2.QolariTagV2 where
  fromTType' (Beam.QolariTagV2T {..}) = do
    pure $
      Just
        Lib.Yudhishthira.Types.QolariTagV2.QolariTagV2
          { actionEngine = actionEngine,
            category = category,
            description = description,
            info = mkTagInfo chakra tagType,
            merchantOperatingCityId = Kernel.Types.Id.Id merchantOperatingCityId,
            name = name,
            possibleValues = mkTagValues rangeEnd rangeStart tags,
            rule = mkTagRule llmContext ruleEngine,
            validity = validity,
            createdAt = createdAt,
            updatedAt = updatedAt
          }

instance ToTType' Beam.QolariTagV2 Lib.Yudhishthira.Types.QolariTagV2.QolariTagV2 where
  toTType' (Lib.Yudhishthira.Types.QolariTagV2.QolariTagV2 {..}) = do
    Beam.QolariTagV2T
      { Beam.actionEngine = actionEngine,
        Beam.category = category,
        Beam.description = description,
        Beam.chakra = getChakra info,
        Beam.tagType = getTag info,
        Beam.merchantOperatingCityId = Kernel.Types.Id.getId merchantOperatingCityId,
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
