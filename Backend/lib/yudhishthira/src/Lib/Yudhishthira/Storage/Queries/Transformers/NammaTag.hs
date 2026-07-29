module Lib.Yudhishthira.Storage.Queries.Transformers.QolariTag where

import qualified Data.Aeson
import Kernel.Prelude
import qualified Lib.Yudhishthira.Types
import qualified Lib.Yudhishthira.Types.QolariTag

getChakra :: (Lib.Yudhishthira.Types.QolariTag.TagInfo -> Kernel.Prelude.Maybe Lib.Yudhishthira.Types.Chakra)
getChakra tag =
  case tag of
    Lib.Yudhishthira.Types.QolariTag.Application -> Kernel.Prelude.Nothing
    Lib.Yudhishthira.Types.QolariTag.KaalChakra (Lib.Yudhishthira.Types.QolariTag.KaalChakraTagInfo chakra) -> Just chakra
    Lib.Yudhishthira.Types.QolariTag.Manual -> Kernel.Prelude.Nothing

getTag :: (Lib.Yudhishthira.Types.QolariTag.TagInfo -> Lib.Yudhishthira.Types.QolariTag.TagType)
getTag tag =
  case tag of
    Lib.Yudhishthira.Types.QolariTag.Application -> Lib.Yudhishthira.Types.QolariTag.ApplicationTag
    Lib.Yudhishthira.Types.QolariTag.KaalChakra _ -> Lib.Yudhishthira.Types.QolariTag.KaalChakraTag
    Lib.Yudhishthira.Types.QolariTag.Manual -> Lib.Yudhishthira.Types.QolariTag.ManualTag

mkTagInfo :: (Kernel.Prelude.Maybe Lib.Yudhishthira.Types.Chakra -> Lib.Yudhishthira.Types.QolariTag.TagType -> Lib.Yudhishthira.Types.QolariTag.TagInfo)
mkTagInfo chakra tagType =
  case tagType of
    Lib.Yudhishthira.Types.QolariTag.ApplicationTag -> Lib.Yudhishthira.Types.QolariTag.Application
    Lib.Yudhishthira.Types.QolariTag.KaalChakraTag -> Lib.Yudhishthira.Types.QolariTag.KaalChakra (Lib.Yudhishthira.Types.QolariTag.KaalChakraTagInfo (fromMaybe Lib.Yudhishthira.Types.Monthly chakra))
    Lib.Yudhishthira.Types.QolariTag.ManualTag -> Lib.Yudhishthira.Types.QolariTag.Manual

getRangeEnd :: (Lib.Yudhishthira.Types.TagValues -> Kernel.Prelude.Maybe Kernel.Prelude.Double)
getRangeEnd = \case
  Lib.Yudhishthira.Types.Range _ end -> Just end
  _ -> Kernel.Prelude.Nothing

getRangeStart :: (Lib.Yudhishthira.Types.TagValues -> Kernel.Prelude.Maybe Kernel.Prelude.Double)
getRangeStart = \case
  Lib.Yudhishthira.Types.Range start _ -> Just start
  _ -> Kernel.Prelude.Nothing

getTags :: (Lib.Yudhishthira.Types.TagValues -> Kernel.Prelude.Maybe [Kernel.Prelude.Text])
getTags = \case
  Lib.Yudhishthira.Types.Range _ _ -> Nothing
  Lib.Yudhishthira.Types.Tags tags -> Just tags
  Lib.Yudhishthira.Types.AnyText -> Nothing

getRuleEngine :: Lib.Yudhishthira.Types.TagRule -> Kernel.Prelude.Maybe Data.Aeson.Value
getRuleEngine = \case
  Lib.Yudhishthira.Types.RuleEngine ruleEngine -> Just ruleEngine
  Lib.Yudhishthira.Types.LLM _ -> Nothing

getLlmContext :: Lib.Yudhishthira.Types.TagRule -> Kernel.Prelude.Maybe Kernel.Prelude.Text
getLlmContext = \case
  Lib.Yudhishthira.Types.RuleEngine _ -> Nothing
  Lib.Yudhishthira.Types.LLM llmContext -> Just llmContext

mkTagValues :: (Kernel.Prelude.Maybe Kernel.Prelude.Double -> Kernel.Prelude.Maybe Kernel.Prelude.Double -> Kernel.Prelude.Maybe [Kernel.Prelude.Text] -> Lib.Yudhishthira.Types.TagValues)
mkTagValues rangeEnd rangeStart mbTags = case mbTags of
  Just tags -> Lib.Yudhishthira.Types.Tags tags
  Nothing -> case (rangeStart, rangeEnd) of
    (Just start, Just end) -> Lib.Yudhishthira.Types.Range start end
    _ -> Lib.Yudhishthira.Types.AnyText

mkTagRule ::
  Kernel.Prelude.Maybe Kernel.Prelude.Text ->
  Kernel.Prelude.Maybe Data.Aeson.Value ->
  Lib.Yudhishthira.Types.TagRule
mkTagRule mbLlmContext mbRuleEngine = case (mbRuleEngine, mbLlmContext) of
  (Just ruleEngine, _) -> Lib.Yudhishthira.Types.RuleEngine ruleEngine
  (_, Just llmContext) -> Lib.Yudhishthira.Types.LLM llmContext
  (Nothing, Nothing) -> Lib.Yudhishthira.Types.RuleEngine Data.Aeson.Null
