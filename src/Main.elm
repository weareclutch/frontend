module Main exposing (fetchSiteDependentResources, getAndDecodePage, init, main, subscriptions, update)

import Dict
import Html.Styled exposing (..)
import Http
import Navigation exposing (Location)
import Ports
import Types exposing (..)
import UI.State exposing (fetchContactInformation, fetchNavigation)
import UI.Wrapper
import Wagtail exposing (getWagtailPage, preloadWagtailPage)


getPageCommands : Wagtail.Page -> List (Cmd Msg)
getPageCommands page =
    case page of
        Wagtail.HomePage _ ->
            [ Ports.playVideos ()
            , Ports.scrollOverlayDown ()
            ]

        Wagtail.CasePage _ ->
            [ Ports.playVideos ()
            ]

        Wagtail.BlogPostPage _ ->
            [ Ports.changeMenuState "BURGERARROW"
            ]

        Wagtail.AboutUsPage _ ->
            [ Ports.bindAboutUs ()
            , Ports.pauseAllVideos ()
            ]

        Wagtail.ServicesPage content ->
            [ Ports.bindServicesPage <|
                List.map .animationName content.expertises
            , Ports.pauseAllVideos ()
            ]

        _ ->
            [ Ports.unbindAll ()
            , Ports.pauseAllVideos ()
            ]


getAndDecodePage : String -> Location -> Cmd Msg
getAndDecodePage apiUrl location =
    getWagtailPage apiUrl location
        |> Cmd.map (\cmd -> WagtailMsg cmd)


fetchSiteDependentResources : String -> Route -> Maybe String -> Cmd Msg
fetchSiteDependentResources apiUrl previousRoute currentIdentifier =
    let
        previousIdentifier =
            case previousRoute of
                WagtailRoute identifier _ ->
                    identifier

                NotFoundRoute identifier ->
                    identifier

                _ ->
                    Nothing

        fetchResourcesForSite id =
            Cmd.batch
                [ fetchNavigation apiUrl id
                , fetchContactInformation apiUrl id
                ]
                |> Cmd.map NavigationMsg
    in
    case ( previousIdentifier, currentIdentifier ) of
        ( _, Nothing ) ->
            Cmd.none

        ( Nothing, Just id ) ->
            fetchResourcesForSite id

        ( Just prevId, Just id ) ->
            if prevId == id then
                Cmd.none

            else
                fetchResourcesForSite id


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        defaultCommands =
            [ getAndDecodePage flags.apiUrl location
            ]

        commands =
            case location.pathname of
                "/" ->
                    Ports.playIntroAnimation () :: defaultCommands

                _ ->
                    defaultCommands
    in
    ( initModel flags, Cmd.batch commands )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    -- let
    --     debugger =
    --         Debug.log "msg" msg
    -- in
    case msg of
        OnLocationChange location ->
            ( model, getAndDecodePage model.flags.apiUrl location )

        ChangeLocation path ->
            ( model, Navigation.newUrl path )

        UpdateSlideshow id direction ->
            ( model, Ports.updateSlideshow ( id, toString direction ) )

        WagtailMsg msg ->
            case msg of
                Wagtail.PreloadPage (Ok page) ->
                    ( { model
                        | navigationTree =
                            model.navigationTree
                                |> Maybe.map (UI.State.addPageToNavigationTree page)
                      }
                    , Cmd.none
                    )

                Wagtail.PreloadPage (Err error) ->
                    Debug.log (toString error)
                        ( { model | route = NotFoundRoute Nothing }, Cmd.none )

                Wagtail.LoadPage (Ok ( response, page )) ->
                    let
                        ( navigationTree, overlayState ) =
                            case model.navigationTree of
                                Nothing ->
                                    ( model.navigationTree, model.overlayState )

                                Just navigationTree ->
                                    let
                                        overlayState =
                                            if UI.State.isNavigationPage navigationTree page then
                                                UI.State.closeOverlay model.overlayState

                                            else
                                                UI.State.addPageToOverlayState model.overlayState page

                                        navTree =
                                            navigationTree
                                                |> UI.State.addPageToNavigationTree page
                                                |> UI.State.setNavigationPageActive page
                                    in
                                    ( Just navTree, overlayState )

                        menuAction =
                            case ( Debug.log "navstate" model.navigationState, overlayState.active ) of
                                ( UI.State.Open _, _ ) ->
                                    Ports.changeMenuState "CROSSBURGER"

                                ( UI.State.Closed, True ) ->
                                    Ports.changeMenuState "BURGERARROW"

                                ( UI.State.Closed, False ) ->
                                    Ports.changeMenuState "ARROWBURGER"

                                _ ->
                                    Cmd.none

                        siteIdentifier =
                            Dict.get "x-current-site" response.headers

                        commands =
                            [ fetchSiteDependentResources model.flags.apiUrl model.route siteIdentifier
                            , Ports.resetScrollPosition ()
                            , menuAction
                            ]
                                ++ getPageCommands page
                    in
                    ( { model
                        | route = WagtailRoute siteIdentifier page
                        , overlayState = overlayState
                        , navigationTree = navigationTree
                        , navigationState = UI.State.Closed
                      }
                    , Cmd.batch commands
                    )

                Wagtail.LoadPage (Err error) ->
                    let
                        route =
                            case error of
                                Http.BadStatus response ->
                                    if response.status.code == 404 then
                                        NotFoundRoute (Dict.get "x-current-site" response.headers)

                                    else
                                        ErrorRoute

                                _ ->
                                    ErrorRoute

                        cmd =
                            case route of
                                NotFoundRoute siteIdentifier ->
                                    fetchSiteDependentResources model.flags.apiUrl model.route siteIdentifier

                                _ ->
                                    Cmd.none

                        _ =
                            Debug.log "Error loading page" error
                    in
                    ( { model | route = route }, cmd )

                Wagtail.UpdateServicesState index ->
                    case ( model.route, model.navigationTree ) of
                        ( WagtailRoute identifier originalPage, Just originalNavigationTree ) ->
                            let
                                page =
                                    case originalPage of
                                        Wagtail.ServicesPage content ->
                                            Wagtail.ServicesPage
                                                { content
                                                    | services = ( index, Tuple.second content.services )
                                                }

                                        _ ->
                                            originalPage

                                navigationTree =
                                    originalNavigationTree
                                        |> UI.State.addPageToNavigationTree page
                            in
                            ( { model
                                | route = WagtailRoute identifier page
                                , navigationTree = Just navigationTree
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Wagtail.UpdateExpertisesState index ->
                    case ( model.route, model.navigationTree ) of
                        ( WagtailRoute identifier (Wagtail.ServicesPage content), Just originalNavigationTree ) ->
                            let
                                expertises =
                                    content.expertises
                                        |> List.indexedMap
                                            (\i expertise ->
                                                if index == i then
                                                    { expertise | active = not expertise.active }

                                                else
                                                    expertise
                                            )

                                id =
                                    "expertise-animation-" ++ toString index

                                command =
                                    expertises
                                        |> List.drop index
                                        |> List.head
                                        |> Maybe.map
                                            (\expertise ->
                                                if expertise.active then
                                                    Ports.playAnimation ( id, expertise.animationName )

                                                else
                                                    Ports.stopAnimation id
                                            )
                                        |> Maybe.withDefault Cmd.none

                                page =
                                    Wagtail.ServicesPage { content | expertises = expertises }

                                navigationTree =
                                    originalNavigationTree
                                        |> UI.State.addPageToNavigationTree page
                            in
                            ( { model
                                | route = WagtailRoute identifier page
                                , navigationTree = Just navigationTree
                              }
                            , command
                            )

                        _ ->
                            ( model, Cmd.none )

        NavigationMsg msg ->
            case msg of
                UI.State.FetchNavigation (Ok navigationTree) ->
                    let
                        ( navTree, overlayState, commands ) =
                            case model.route of
                                WagtailRoute _ page ->
                                    let
                                        overlayState =
                                            if UI.State.isNavigationPage navigationTree page then
                                                UI.State.closeOverlay model.overlayState

                                            else
                                                UI.State.addPageToOverlayState model.overlayState page

                                        navTree =
                                            navigationTree
                                                |> UI.State.addPageToNavigationTree page
                                                |> UI.State.setNavigationPageActive page
                                    in
                                    ( navTree, overlayState, getPageCommands page )

                                _ ->
                                    ( navigationTree, model.overlayState, [] )
                    in
                    ( { model
                        | overlayState = overlayState
                        , navigationTree = Just navTree
                        , navigationState = UI.State.Closed
                      }
                    , Cmd.batch (Ports.setupNavigation () :: commands)
                    )

                UI.State.FetchNavigation (Err error) ->
                    Debug.log (toString error)
                        ( { model | navigationTree = Nothing }, Cmd.none )

                UI.State.ChangeNavigation newState ->
                    let
                        pageCommand =
                            case newState of
                                UI.State.Open index ->
                                    model.navigationTree
                                        |> Maybe.andThen
                                            (\navigationTree ->
                                                navigationTree.items
                                                    |> List.drop index
                                                    |> List.head
                                            )
                                        |> Maybe.andThen
                                            (\activeNavItem ->
                                                case activeNavItem.page of
                                                    Just _ ->
                                                        Nothing

                                                    Nothing ->
                                                        Just <|
                                                            Cmd.map
                                                                (\cmd -> WagtailMsg cmd)
                                                                (preloadWagtailPage model.flags.apiUrl activeNavItem.path)
                                            )
                                        |> Maybe.withDefault Cmd.none

                                _ ->
                                    Cmd.none

                        menuCommand =
                            case ( model.navigationState, newState ) of
                                ( UI.State.Open _, UI.State.Closed ) ->
                                    Ports.changeMenuState "CROSSBURGER"

                                (UI.State.OpenContact, UI.State.Closed) ->
                                    Ports.changeMenuState "CROSSBURGER"

                                (UI.State.Closed, UI.State.Open _) ->
                                    Ports.changeMenuState "BURGERCROSS"

                                ( UI.State.Closed, UI.State.OpenContact ) ->
                                    Ports.changeMenuState "BURGERCROSS"

                                _ ->
                                    Cmd.none
                    in
                    ( { model | navigationState = newState }
                    , Cmd.batch [ menuCommand, pageCommand ]
                    )

                UI.State.FetchContactInformation (Ok contactInfo) ->
                    ( { model | contactInformation = Just contactInfo }, Cmd.none )

                UI.State.FetchContactInformation (Err error) ->
                    Debug.log (toString error)
                        ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []




main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = UI.Wrapper.view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }

