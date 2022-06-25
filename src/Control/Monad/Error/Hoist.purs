module Control.Monad.Error.Hoist where

import Control.Applicative (pure)
import Control.Bind ((>>=))
import Control.Monad.Error.Class (class MonadThrow, throwError)
import Control.Monad.Except (ExceptT, runExceptT)
import Data.Either (Either, either)
import Data.Function (flip, (<<<))
import Data.Maybe (Maybe, maybe)
import Data.Unit (Unit, unit)

class HoistError ∷ Type → Type → (Type → Type) → (Type → Type) → Constraint
class HoistError e e' n m | n → e where
  hoistError ∷ ∀ a. (e → e') → n a → m a

instance MonadThrow e m ⇒ HoistError Unit e Maybe m where
  hoistError ∷ ∀ a. (Unit → e) → Maybe a → m a
  hoistError f = maybe (throwError (f unit)) pure

instance MonadThrow e' m ⇒ HoistError e e' (Either e) m where
  hoistError ∷ ∀ a. (e → e') → Either e a → m a
  hoistError f = either (throwError <<< f) pure

instance MonadThrow e' m ⇒ HoistError e e' (ExceptT e m) m where
  hoistError ∷ ∀ a. (e → e') → ExceptT e m a → m a
  hoistError f m = runExceptT m >>= hoistError f

hoistErrorFlipped ∷ ∀ e e' n m a. HoistError e e' m n ⇒ m a → (e → e') → n a
hoistErrorFlipped = flip hoistError

infixl 8 hoistErrorFlipped as <%?>

hoistErrorId ∷ ∀ e m n a. HoistError e e n m ⇒ n a → m a
hoistErrorId = hoistError \(e ∷ e) → e

hoistError_ ∷ ∀ x e m n a. HoistError x e n m ⇒ e → n a → m a
hoistError_ e = hoistError \_ → e

hoistErrorFlipped_ ∷ ∀ x e m n a. HoistError x e n m ⇒ n a → e → m a
hoistErrorFlipped_ = flip hoistError_

infixl 8 hoistErrorFlipped_ as <?>
