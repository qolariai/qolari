{-
  Copyright 2026, Qolari Technologies

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Lib.Yudhishthira.Storage.Beam.BeamFlow where

import Kernel.Beam.Lib.UtilsTH as Reexport
import Kernel.Types.Common as Reexport hiding (id)
import Kernel.Utils.Common
import qualified Lib.Yudhishthira.Storage.Beam.AppDynamicLogicAlwaysOn as BeamADAO
import qualified Lib.Yudhishthira.Storage.Beam.AppDynamicLogicElement as BeamADLE
import qualified Lib.Yudhishthira.Storage.Beam.AppDynamicLogicRollout as BeamADLR
import qualified Lib.Yudhishthira.Storage.Beam.ChakraQueries as BeamCQ
import qualified Lib.Yudhishthira.Storage.Beam.QolariTag as BeamNT
import qualified Lib.Yudhishthira.Storage.Beam.QolariTagTrigger as BeamNTT
import qualified Lib.Yudhishthira.Storage.Beam.QolariTagTriggerV2 as BeamNTTV2
import qualified Lib.Yudhishthira.Storage.Beam.QolariTagV2 as BeamNTV2
import qualified Lib.Yudhishthira.Storage.Beam.TagActionNotificationConfig as BeamTANC
import qualified Lib.Yudhishthira.Storage.Beam.TimeBoundConfig as BeamTMC
import qualified Lib.Yudhishthira.Storage.Beam.UserData as BeamUD

type BeamFlow m r =
  ( MonadFlow m,
    EsqDBFlow m r,
    CacheFlow m r,
    HasYudhishthiraTablesSchema
  )

type HasYudhishthiraTablesSchema =
  ( HasSchemaName BeamADAO.AppDynamicLogicAlwaysOnT,
    HasSchemaName BeamADLR.AppDynamicLogicRolloutT,
    HasSchemaName BeamADLE.AppDynamicLogicElementT,
    HasSchemaName BeamCQ.ChakraQueriesT,
    HasSchemaName BeamNT.QolariTagT,
    HasSchemaName BeamNTT.QolariTagTriggerT,
    HasSchemaName BeamNTTV2.QolariTagTriggerV2T,
    HasSchemaName BeamNTV2.QolariTagV2T,
    HasSchemaName BeamUD.UserDataT,
    HasSchemaName BeamTANC.TagActionNotificationConfigT,
    HasSchemaName BeamTMC.TimeBoundConfigT
  )
