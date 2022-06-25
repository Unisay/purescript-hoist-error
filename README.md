# purescript-hoist-error

Provides a typeclass and useful combinators for hoisting errors into a monad.

`HoistError` extends `MonadThrow` with `hoistError`, which enables lifting of partiality types such as `Maybe` and `Either e` into the monad.

For example, consider the following App monad that may throw `BadPacket` errors:

```purescript
data AppError = BadPacket String

newtype App a = App (ExceptT AppError Aff) a

instance Functor App where ...
instance Apply App where ...
instance Applicative App where ...
instance Bind App where
instance Monad App
instance MonadThrow AppError where ...
```

We may have an existing function that parses a String into a Maybe Packet

```purescript
parsePacket :: String -> Maybe Packet
```

which can be lifted into the `App` monad with `hoistError`

```purescript
appParsePacket :: String -> App Packet
appParsePacket s = hoistError (parsePacket s) \_ -> BadPacket "no parse"
```

Similar instances exist for `Either e` and `ExceptT e m`.

Operator alias `<%?>` is provided for a syntactic convenience:
```purescript
appParsePacket :: String -> App Packet
appParsePacket s = parsePacket s <%?> \_ -> BadPacket "no parse"
```

Inspired by: https://hackage.haskell.org/package/hoist-error-0.2.1.0/docs/Control-Monad-Error-Hoist.html
