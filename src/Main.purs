module Main where

import Prelude
import Data.Int as Int
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Node.Process as Process
import Payload.Server (LogLevel(..))
import Payload.Server as Payload
import Payload.Spec (Spec(Spec), GET)

type Message
  = { id :: Int
    , text :: String
    }

spec ::
  Spec
    { getMessages ::
        GET "/users/<id>/messages?limit=<limit>"
          { params :: { id :: Int }
          , query :: { limit :: Int }
          , response :: Array Message
          }
    }
spec = Spec

getMessages ::
  { params :: { id :: Int }
  , query :: { limit :: Int }
  } ->
  Aff (Array Message)
getMessages { params: { id }, query: { limit } } =
  pure
    [ { id: 1, text: "Hey " <> show id }
    , { id: 2, text: "Limit " <> show limit }
    ]

handlers = { getMessages }

main :: Effect Unit
main = do
  portEnv <- Process.lookupEnv "PORT"
  case portEnv >>= Int.fromString of
    Nothing -> mempty
    Just port ->
      launchAff_ do
        Payload.start
          options
          spec
          handlers
      where
      options =
        { backlog: Nothing
        , hostname: "0.0.0.0"
        , logLevel: LogNormal
        , port
        }
