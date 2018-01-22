module Routing exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        ]


getCommand : Route -> Model -> Cmd Msg
getCommand route model =
    Cmd.none


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
