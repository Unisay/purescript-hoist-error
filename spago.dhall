{ name = "purescript-hoist-error"
, dependencies =
  [ "aff"
  , "bifunctors"
  , "effect"
  , "either"
  , "maybe"
  , "prelude"
  , "strings"
  , "test-unit"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
