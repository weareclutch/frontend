module Main exposing (..)

import Browser
import Browser.Navigation
import Url
import Http
import Dict
import Html.Styled exposing (..)
import Ports
import Types exposing (Msg(..))
import Wagtail exposing (getWagtailPage, preloadWagtailPage)
import UI.State exposing (fetchContactInformation, fetchNavigation)
import UI.Wrapper


view : Types.Model -> Html msg
view model =
    h1 [] [ text "foobar" ]


main : Program Types.Flags Types.Model Msg
main =
    Browser.application
        { init = init
        , view = \model -> { title = "foo", body = [UI.Wrapper.view model |> toUnstyled ] }
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \url -> UrlChanged url
        , onUrlRequest = LinkClicked
        }


init : Types.Flags -> Url.Url -> Browser.Navigation.Key -> ( Types.Model, Cmd Msg )
init flags url key =
    let
        defaultCommands =
            [ getAndDecodePage flags.apiUrl url
            ]

        commands =
            case url.path of
                "/" ->
                    Ports.playIntroAnimation () :: defaultCommands

                _ ->
                    defaultCommands
    in
    ( Types.initModel flags key, Cmd.batch commands )

fetchSiteDependentResources : String -> Types.Route -> Maybe String -> Cmd Msg
fetchSiteDependentResources apiUrl previousRoute currentIdentifier =
    let
        previousIdentifier =
            case previousRoute of
                Types.WagtailRoute identifier _ ->
                    identifier

                Types.NotFoundRoute identifier ->
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

getAndDecodePage : String -> Url.Url -> Cmd Msg
getAndDecodePage apiUrl url =
    getWagtailPage apiUrl url
        |> Cmd.map (\cmd -> WagtailMsg cmd)

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


update : Msg -> Types.Model -> ( Types.Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( model, getAndDecodePage model.flags.apiUrl url )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UpdateSlideshow id direction ->
            ( model
            , Ports.updateSlideshow
                ( id
                , case direction of
                      Types.Left ->
                          "Left"
                      Types.Right ->
                          "Right"
                )
            )

        WagtailMsg wagtailMsg ->
            case wagtailMsg of
                Wagtail.PreloadPage (Ok page) ->
                    ( { model
                        | navigationTree =
                            model.navigationTree
                                |> Maybe.map (UI.State.addPageToNavigationTree page)
                      }
                    , Cmd.none
                    )

                Wagtail.PreloadPage (Err error) ->
                    Debug.log "preloading page failed"
                        ( { model | route = Types.NotFoundRoute Nothing }, Cmd.none )

                Wagtail.LoadPage (Ok ( response, page )) ->
                    let
                        ( newNavigationTree, newOverlayState ) =
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
                            case ( Debug.log "navstate" model.navigationState, newOverlayState.active ) of
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
                        | route = Types.WagtailRoute siteIdentifier page
                        , overlayState = newOverlayState
                        , navigationTree = newNavigationTree
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
                                        Types.NotFoundRoute (Dict.get "x-current-site" response.headers)

                                    else
                                        Types.ErrorRoute

                                _ ->
                                    Types.ErrorRoute

                        cmd =
                            case route of
                                Types.NotFoundRoute siteIdentifier ->
                                    fetchSiteDependentResources model.flags.apiUrl model.route siteIdentifier

                                _ ->
                                    Cmd.none

                        _ =
                            Debug.log "Error loading page" error
                    in
                    ( { model | route = route }, cmd )

                Wagtail.UpdateServicesState index ->
                    case ( model.route, model.navigationTree ) of
                        ( Types.WagtailRoute identifier originalPage, Just originalNavigationTree ) ->
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
                                | route = Types.WagtailRoute identifier page
                                , navigationTree = Just navigationTree
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Wagtail.UpdateExpertisesState index ->
                    case ( model.route, model.navigationTree ) of
                        ( Types.WagtailRoute identifier (Wagtail.ServicesPage content), Just originalNavigationTree ) ->
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
                                    "expertise-animation-" ++ String.fromInt index

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
                                | route = Types.WagtailRoute identifier page
                                , navigationTree = Just navigationTree
                              }
                            , command
                            )

                        _ ->
                            ( model, Cmd.none )


        NavigationMsg navigationMsg ->
            case navigationMsg of
                UI.State.FetchNavigation (Ok navigationTree) ->
                    let
                        ( newNavTree, newOverlayState, commands ) =
                            case model.route of
                                Types.WagtailRoute _ page ->
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
                        | overlayState = newOverlayState
                        , navigationTree = Just newNavTree
                        , navigationState = UI.State.Closed
                      }
                    , Cmd.batch (Ports.setupNavigation () :: commands)
                    )

                UI.State.FetchNavigation (Err error) ->
                    Debug.log "failed to fetch navigation"
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
                    Debug.log "failed to fetch contact information"
                        ( model, Cmd.none )

