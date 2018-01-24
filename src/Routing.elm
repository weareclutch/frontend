module Routing exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Api exposing (getPage, getPageById)
import Task
import Http
import Dict


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
            case Dict.get (toString Home) model.pages of
                Just page ->
                    Task.succeed (Ok page)
                        |> Task.perform OpenPage

                Nothing -> 
                    getPage Home
                        |> Http.send OpenPage

        CaseRoute id title ->
            case Dict.get id model.cases of
                Just page ->
                    Task.succeed (Ok page)
                        |> Task.perform OpenCase

                Nothing ->
                    getPageById Case id
                        |> Http.send OpenCase

        _ ->
            Cmd.none


parseLocation : Location -> Route
parseLocation location =
    case parsePath matchers location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

