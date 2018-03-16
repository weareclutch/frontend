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
import Regex
import Api exposing (siteUrl)
import Task
import Process
import Time


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
    , parallaxPositions = Dict.empty
    , windowDimensions = ( 0, 0 )
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

        _ ->
            Nothing


getPageCommand : Model -> Page -> Cmd Msg
getPageCommand model page =
    case page of
        Home content ->
            if (Dict.get content.pageType model.pages == Nothing) then
                content.animation
                    |> Maybe.map
                        (Regex.replace
                            Regex.All
                            (Regex.regex "http://localhost")
                            (\_ -> siteUrl)
                        )
                    |> Ports.showHomeIntro
            else
                Cmd.none

        _ ->
            Cmd.none


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
                        let
                            cmd =
                                getPageCommand model page
                        in
                            ( { model
                                | activePage = Just pageType
                                , activeCase = Nothing
                                , activeOverlay = Nothing
                                , activeService = Nothing
                                , menuState = Closed
                                , pages =
                                    model.pages
                                        |> Dict.insert pageType page
                              }
                            , cmd
                            )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        OpenPage (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        OpenCase (Ok content) ->
            let
                cases =
                    Dict.insert content.meta.id content model.cases

                ( activeOverlay, cmd ) =
                    case model.activeCase of
                        Just _ ->
                            ( model.activeOverlay, Cmd.none )

                        Nothing ->
                            ( Just content.meta.id, Ports.getCasePosition content.meta.id )
            in
                ( { model
                    | cases = cases
                    , activeCase = Just content
                    , menuState = Closed
                    , activeOverlay = activeOverlay
                  }
                , cmd
                )

        OpenCase (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )

        SetCasePosition position ->
            ( { model | casePosition = position }, Cmd.none )

        RepositionCase ( x, y ) ->
            let
                ( oldX, oldY ) =
                    model.casePosition

                newPosition =
                    ( oldX + x
                    , oldY + y
                    )
            in
                ( { model | casePosition = newPosition }, Cmd.none )

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

                        OpenTopContact ->
                            Closed

                        OpenBottomContact ->
                            Closed

            in
                ( { model | menuState = menuState }, Cmd.none )

        OpenContact ->
            let
                menuState =
                    case model.menuState of
                        OpenTop ->
                            OpenTopContact

                        OpenBottom ->
                            OpenBottomContact

                        _ ->
                            OpenTopContact

            in
                ( { model | menuState = menuState }, Cmd.none )


        OpenMenu state ->
            ( { model | menuState = state }, Cmd.none )

        OpenService service ->
            ( { model | activeService = Just service }, Cmd.none )

        CloseService ->
            ( { model | activeService = Nothing }, Cmd.none )

        SpinEasterEgg acc step ->
            model.pages
                |> Dict.get "home.HomePage"
                |> Maybe.andThen
                    (\page ->
                        case page of
                            Home content ->
                                Just content

                            _ ->
                                Nothing
                    )
                |> Maybe.andThen
                    (\content ->
                        case content.easterEggImages of
                            hd::tl ->
                                Just { content | easterEggImages = tl ++ [ hd ] }

                            _ ->
                                Nothing
                    )
                |> Maybe.map
                    (\content ->
                        let
                            pages =
                                model.pages
                                    |> Dict.insert "home.HomePage" (Home content)

                            cmd =
                                if acc < 380 then
                                    Process.sleep ((acc + step))
                                        |> Task.perform
                                            (\_ ->
                                                SpinEasterEgg
                                                    (acc + step)
                                                    (step * 1.15)
                                                    |> Debug.log "spin!"
                                            )
                                else
                                    Cmd.none

                        in
                            ( { model | pages = pages }, cmd )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        SetParallaxPositions list ->
            ( { model | parallaxPositions = Dict.fromList list }, Cmd.none )

        SetWindowDimensions dimensions ->
            ( { model | windowDimensions = Debug.log "dim" dimensions }, Cmd.none )

        ScrollEvent pageType pos ->
            let
                positions =
                    Dict.insert pageType pos model.pageScrollPositions
            in
                ( { model | pageScrollPositions = positions }, Cmd.none )



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
        [ Ports.newCasePosition (Ports.decodePosition SetCasePosition)
        , Ports.repositionCase (Ports.decodePosition RepositionCase)
        , Ports.changeMenu Ports.decodeDirection
        , Ports.getParallaxPositions Ports.decodeParallaxPositions
        , Ports.setWindowDimensions SetWindowDimensions
        ]


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
