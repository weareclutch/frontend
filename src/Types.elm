module Types exposing (..)

import Navigation exposing (Location)
import Wagtail
import UI.State

type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | NavigationMsg UI.State.Msg
    | WagtailMsg Wagtail.Msg


type alias Model =
    { route : Route
    , overlayState : UI.State.OverlayState
    , navigationState : UI.State.NavigationState
    , navigationTree : Maybe UI.State.NavigationTree
    }


initModel : Model
initModel =
    { route = UndefinedRoute
    , overlayState =
        { active = False
        , parts = (Nothing, Nothing)
        }
    , navigationState = UI.State.Closed
    , navigationTree = Nothing
    }

type alias SiteIdentifier = Maybe String

type Route
    = UndefinedRoute
    | WagtailRoute SiteIdentifier Wagtail.Page
    | NotFoundRoute SiteIdentifier
    | ErrorRoute



