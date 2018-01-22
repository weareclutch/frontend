module Types exposing (..)

import Navigation exposing (Location)


type Msg
    = OnLocationChange Location
    | ChangeLocation String


type alias Model =
    { route : Route
    }


type Route
    = HomeRoute
    | NotFoundRoute
