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
import UI.Pages.Services
import Ports


initModel : Route -> Model
initModel route =
    { route = route
    , pages = Dict.empty
    , activePage = Nothing
    , cases = Dict.empty
    , activeCase = Nothing
    , activeOverlay = Nothing
    , activeService = Nothing
    , casePosition = ( 0, 0 )
    , menuState = Closed
    , pageScrollPositions = Dict.empty
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
                            , activeOverlay = Nothing
                            , activeService = Nothing
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

                ( activeOverlay, cmd ) =
                    case model.activeCase of
                        Just _ ->
                            ( model.activeOverlay, Cmd.none )

                        Nothing ->
                            ( Just content.id, Ports.getCasePosition content.id )
            in
                ( { model
                    | cases = cases
                    , activeCase = Just content
                    , activeOverlay = activeOverlay
                  }
                , cmd
                )

        OpenCase (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        SetCasePosition position ->
            ( { model | casePosition = position }, Cmd.none )

        ToggleMenu ->
            let
                menuState =
                    case model.menuState of
                        Closed ->
                            OpenTop

                        OpenTop ->
                            Closed

                        OpenBottom ->
                            Closed
            in
                ( { model | menuState = menuState }, Cmd.none )

        OpenMenu state ->
            ( { model | menuState = state }, Cmd.none )

        OpenService service ->
            ( { model | activeService = Just service }, Cmd.none )

        CloseService ->
            ( { model | activeService = Nothing }, Cmd.none )

        SetPageScrollPosition pos ->
            let
                pageScrollPositions =
                    model.activePage
                        |> Maybe.map
                            (\activePage ->
                                case model.activeOverlay of
                                    Just id ->
                                        toString id

                                    Nothing ->
                                        activePage
                            )
                        |> Maybe.map
                            (\key ->
                                Dict.insert key pos model.pageScrollPositions
                            )
                        |> Maybe.withDefault model.pageScrollPositions
            in
                ( { model | pageScrollPositions = pageScrollPositions }, Cmd.none )


view : Model -> Html Msg
view model =
    UI.Wrapper.view model
        [ UI.Navigation.view model
        , UI.Page.container model
        , UI.Case.staticView model
        , UI.Pages.Services.overlay model.activeService
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.newCasePosition Ports.decodePosition
        , Ports.changeMenu Ports.decodeDirection
        , Ports.setScrollPosition SetPageScrollPosition
        ]


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
