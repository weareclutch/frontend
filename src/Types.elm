module Types exposing (..)

import Navigation exposing (Location)
import Http
import Dict exposing (Dict)


type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | AddPage (Result Http.Error Page)


type alias Model =
    { route : Route
    , pages : Dict Int Page
    }


type Route
    = HomeRoute
    | CaseRoute Int String
    | NotFoundRoute


type alias Page =
    { id : Int
    , title : String
    }
