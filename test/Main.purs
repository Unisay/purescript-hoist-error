module Test.Main where

import Prelude

import Control.Monad.Error.Class (try)
import Control.Monad.Error.Hoist ((<%?>))
import Control.Monad.Except (ExceptT, except)
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String as Str
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Test.Unit (suite, test)
import Test.Unit.Assert (shouldEqual)
import Test.Unit.Main (runTest)

main ∷ Effect Unit
main = runTest $ suite "Control.Monad.Error.Hoist" do
  test "Maybe" do
    (Just 42 <%?> \_ → "error")
      `shouldEqual` Right 42
    ((Nothing ∷ Maybe Int) <%?> const "error")
      `shouldEqual` Left "error"
  test "Either" do
    ((Left "error" ∷ Either _ Unit) <%?> Str.length)
      `shouldEqual` Left 5
    ((Right 1 ∷ Either String _) <%?> \_ → "error")
      `shouldEqual` Right 1
  test "ExceptT" do
    let
      withError ∷ ExceptT String Aff Unit
      withError = except (Left "e")

      withoutError ∷ ExceptT String Aff Unit
      withoutError = except (Right unit)

    res ← try (withError <%?> Aff.error)
    lmap Aff.message res `shouldEqual` (Left "e")

    (withoutError <%?> Aff.error) >>= shouldEqual unit

