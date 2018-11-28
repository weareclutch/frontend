module Types exposing (Model, Direction(..), Msg(..), Route(..), SiteIdentifier, initModel)

import Navigation exposing (Location)
import UI.State
import Wagtail


type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | NavigationMsg UI.State.Msg
    | WagtailMsg Wagtail.Msg
    | UpdateSlideshow String Direction


type Direction
    = Left
    | Right


type alias Model =
    { route : Route
    , overlayState : UI.State.OverlayState
    , navigationState : UI.State.NavigationState
    , navigationTree : Maybe UI.State.NavigationTree
    , contactInformation : Maybe UI.State.ContactInformation
    }


initModel : Model
initModel =
    { route = UndefinedRoute
    , overlayState =
        { active = False
        , parts = ( Nothing, Nothing )
        }
    , navigationState = UI.State.Closed
    , navigationTree = Nothing
    , contactInformation = Nothing
    }


type alias SiteIdentifier =
    Maybe String


type Route
    = UndefinedRoute
    | WagtailRoute SiteIdentifier Wagtail.Page
    | NotFoundRoute SiteIdentifier
    | ErrorRoute
