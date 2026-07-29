module Lib.Yudhishthira.Storage.Queries.QolariTagExtra where

import Kernel.Beam.Functions
import Kernel.Prelude
import qualified Lib.Yudhishthira.Storage.Beam.BeamFlow as BeamFlow
import qualified Lib.Yudhishthira.Storage.Beam.QolariTag as Beam
import Lib.Yudhishthira.Storage.Queries.OrphanInstances.QolariTag ()
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTag
import Sequelize as Se

-- Extra code goes here --
findAllByChakra :: BeamFlow.BeamFlow m r => Lib.Yudhishthira.Types.Chakra -> m [Lib.Yudhishthira.Types.QolariTag.QolariTag]
findAllByChakra chakra = do findAllWithKV [Se.And [Se.Is Beam.chakra $ Se.Eq (Just chakra)]]

findAll :: BeamFlow.BeamFlow m r => m [Lib.Yudhishthira.Types.QolariTag.QolariTag]
findAll = findAllWithKV @Beam.QolariTagT []
