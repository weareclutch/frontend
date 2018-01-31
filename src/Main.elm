module Main exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation, getCommand)
import Html.Styled exposing (..)
import Dict exposing (Dict)
import UI.Wrapper
-- import UI.Navigation
-- import UI.Case
-- import UI.Page
import Ports


initModel : Route -> Model
initModel route =
    { route = route
    , pages = Dict.empty
    , activePage = Nothing
    , cases = Dict.empty
    , activeCase = Nothing
    , casePosition = ( 0, 0 )
    , menuActive = False
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            parseLocation location

        command =
            getCommand route <| initModel NotFoundRoute
    in
        ( initModel route, command )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                command =
                    getCommand newRoute model
            in
                ( { model | route = newRoute }, command )

        ChangeLocation path ->
            ( model, Navigation.newUrl path )

        OpenPage (Ok page) ->
             ( { model
                    | activePage = Just page
                    , activeCase = Nothing
                  }
                , Cmd.none
                )

        OpenPage (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        OpenCase (Ok page) ->
               ( { model
                  | activeCase = Just page
                 }
                 , Cmd.none
                 -- , Ports.getCasePosition page.id
               )

        OpenCase (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        SetCasePosition position ->
            ( { model | casePosition = position }, Cmd.none )

        ToggleMenu ->
            ( { model | menuActive = not model.menuActive }, Cmd.none )


view : Model -> Html Msg
view model =
    UI.Wrapper.view model
        []
        -- [ UI.Navigation.view
        -- , UI.Case.view model
        -- , UI.Page.container model
        -- ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.newCasePosition Ports.decodePosition


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
