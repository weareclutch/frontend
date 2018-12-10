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
            [ Ports.scrollOverlayDown ()
            ]

        Wagtail.AboutUsPage _ ->
            [ Ports.bindAboutUs ()
            ]

        Wagtail.ServicesPage content ->
            [ Ports.bindServicesPage
                <| List.map .animationName content.expertises
            ]

        _ ->
            [ Ports.unbindAll ()
            ]


getAndDecodePage : Location -> Cmd Msg
getAndDecodePage location =
    getWagtailPage location
        |> Cmd.map (\cmd -> WagtailMsg cmd)


fetchSiteDependentResources : Route -> Maybe String -> Cmd Msg
fetchSiteDependentResources previousRoute currentIdentifier =
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
                [ fetchNavigation id
                , fetchContactInformation id
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


init : Location -> ( Model, Cmd Msg )
init location =
    let
        defaultCommands =
            [ getAndDecodePage location
            ]

        commands =
            case location.pathname of
                "/" ->
                    Ports.playIntroAnimation () :: defaultCommands

                _ ->
                    defaultCommands
    in
    ( initModel, Cmd.batch commands )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        debugger =
            Debug.log "msg" msg

    in
    case msg of
        OnLocationChange location ->
            ( model, getAndDecodePage location )

        ChangeLocation path ->
            ( model, Navigation.newUrl path )

        UpdateSlideshow id direction ->
            ( model, Ports.updateSlideshow (id, toString direction) )

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

                        siteIdentifier =
                            Dict.get "x-current-site" response.headers

                        commands =
                            [ fetchSiteDependentResources model.route siteIdentifier
                            , Ports.resetScrollPosition ()
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
                                    fetchSiteDependentResources model.route siteIdentifier

                                _ ->
                                    Cmd.none

                        _ =
                            Debug.log "Error loading page" error
                    in
                    ( { model | route = route }, cmd )

                Wagtail.UpdateServicesState index ->
                    case (model.route, model.navigationTree) of
                        (WagtailRoute identifier originalPage, Just originalNavigationTree) ->
                            let
                                page =
                                    case originalPage of
                                        Wagtail.ServicesPage content ->
                                            Wagtail.ServicesPage
                                              { content
                                              | services = (index, Tuple.second content.services)
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
                                , Cmd.none )

                        _ ->
                            ( model, Cmd.none )

                Wagtail.UpdateExpertisesState index ->
                    case (model.route, model.navigationTree) of
                        (WagtailRoute identifier (Wagtail.ServicesPage content), Just originalNavigationTree) ->
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
                                    "expertise-animation-" ++ (toString index)

                                command =
                                    expertises
                                        |> List.drop index
                                        |> List.head
                                        |> Maybe.map
                                            (\expertise ->
                                                if expertise.active then
                                                    Ports.playAnimation ( id , expertise.animationName )
                                                else
                                                    Ports.stopAnimation id
                                            )
                                        |> Maybe.withDefault (Cmd.none)

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
                                , command )


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
                                    ( navigationTree, model.overlayState, [ Cmd.none ] )
                    in
                    ( { model
                        | overlayState = overlayState
                        , navigationTree = Just navTree
                        , navigationState = UI.State.Closed
                      }
                    , Cmd.batch commands
                    )

                UI.State.FetchNavigation (Err error) ->
                    Debug.log (toString error)
                        ( { model | navigationTree = Nothing }, Cmd.none )

                UI.State.ChangeNavigation newState ->
                    case newState of
                        UI.State.Open index ->
                            let
                                command =
                                    model.navigationTree
                                        |> Maybe.andThen
                                            (\navigationTree ->
                                                navigationTree.items
                                                    |> List.drop index
                                                    |> List.head
                                            )
                                        |> Maybe.map
                                            (\activeNavItem ->
                                                preloadWagtailPage activeNavItem.path
                                                    |> Cmd.map (\cmd -> WagtailMsg cmd)
                                            )
                            in
                            ( { model | navigationState = newState }
                            , Maybe.withDefault Cmd.none command
                            )

                        _ ->
                            ( { model | navigationState = newState }, Cmd.none )

                UI.State.FetchContactInformation (Ok contactInfo) ->
                    ( { model | contactInformation = Just contactInfo }, Cmd.none )

                UI.State.FetchContactInformation (Err error) ->
                    Debug.log (toString error)
                        ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch []



-- [ Ports.newCasePosition (Ports.decodePosition SetCasePosition)
-- , Ports.repositionCase (Ports.decodePosition RepositionCase)
-- , Ports.changeMenu Ports.decodeDirection
-- , Ports.getParallaxPositions Ports.decodeParallaxPositions
-- , Ports.setWindowDimensions SetWindowDimensions
-- ]


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = UI.Wrapper.view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
