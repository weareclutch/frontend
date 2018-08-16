module Routing exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import UrlParser exposing (..)
import Api exposing (getPage, getCaseById)
import Task
import Http
import Dict




getCommand : Route -> Model -> Cmd Msg
getCommand route model =
    case route of

        _ ->
            Cmd.none

