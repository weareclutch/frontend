module Routing exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Api exposing (getHomePage, getCasePage)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map HomeRoute top
        , map CaseRoute (int </> string)
        ]


getCommand : Route -> Model -> Cmd Msg
getCommand route model =
    case route of
        HomeRoute ->
            getHomePage

        CaseRoute id _ ->
            getCasePage id

        _ ->
            Cmd.none


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
