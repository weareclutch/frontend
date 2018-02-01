module Main exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation, getCommand)
import Html.Styled exposing (..)
import Dict exposing (Dict)
import UI.Wrapper
import UI.Navigation
import UI.Case
import UI.Page
import Ports


initModel : Route -> Model
initModel route =
    { route = route
    , pages = Dict.empty
    , activePage = Nothing
    , cases = Dict.empty
    , activeCase = Nothing
    , casePosition = ( 0, 0 )
    , menuState = Closed
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


getPageType : Page -> Maybe String
getPageType page =
    case page of
        Home { pageType } ->
            Just pageType

        Services { pageType } ->
            Just pageType

        Culture { pageType } ->
            Just pageType

        Contact { pageType } ->
            Just pageType

        _ ->
            Nothing


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
            getPageType page
                |> Maybe.map
                    (\pageType ->
                        ( { model
                            | activePage = Just pageType
                            , activeCase = Nothing
                            , pages =
                                model.pages
                                    |> Dict.insert pageType page
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        OpenPage (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        OpenCase (Ok content) ->
            let
                cases =
                    Dict.insert content.id content model.cases
            in
                ( { model
                    | cases = cases
                    , activeCase = Just content
                  }
                , Ports.getCasePosition content.id
                )

        OpenCase (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        SetCasePosition position ->
            ( { model | casePosition = position }, Cmd.none )

        CloseMenu ->
            ( { model | menuState = Closed }, Cmd.none )

        OpenMenu state ->
            ( { model | menuState = state }, Cmd.none )


view : Model -> Html Msg
view model =
    UI.Wrapper.view model
        [ UI.Navigation.view
        , UI.Page.container model
        , UI.Case.view model
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newCasePosition Ports.decodePosition
        , Ports.changeMenu Ports.decodeDirection
        ]


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
