module Main exposing (..)

import Navigation exposing (Location)
import Html.Styled exposing (..)
import UI.Wrapper
import Wagtail exposing (getWagtailPage, preloadWagtailPage)
import UI.State exposing (fetchNavigation)
import Ports
import Types exposing (..)


getAndDecodePage : Location -> Cmd Msg
getAndDecodePage location =
    getWagtailPage location
      |> Cmd.map (\cmd -> WagtailMsg cmd)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        defaultCommands =
            [ getAndDecodePage location
            , fetchNavigation |> Cmd.map (\cmd -> NavigationMsg cmd)
            ]

        commands =
            case location.pathname of
                "/" -> Ports.playAnimation () :: defaultCommands
                _ -> defaultCommands
    in
        ( initModel , Cmd.batch commands )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            (model, getAndDecodePage location)

        ChangeLocation path ->
            (model, Navigation.newUrl path)


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
                    Debug.log (toString error) (\x -> x)
                    ({ model | route = NotFoundRoute }, Cmd.none)

                Wagtail.LoadPage (Ok page) ->
                    let
                        defaultCommands =
                          [ Ports.resetScrollPosition ()
                          ] 

                        commands =
                          case page of
                              Wagtail.HomePage _ -> Ports.scrollOverlayDown ()
                              _ -> Cmd.none

                    in
                        ( { model
                            | route = WagtailRoute page
                            , overlayState =
                                model.navigationTree
                                |> Maybe.map
                                      (\navigationTree ->
                                            if (UI.State.isNavigationPage navigationTree page) then
                                                UI.State.closeOverlay model.overlayState
                                            else
                                                UI.State.addPageToOverlayState model.overlayState page
                                      )
                                |> Maybe.withDefault model.overlayState

                            , navigationTree =
                                model.navigationTree
                                |> Maybe.map (UI.State.addPageToNavigationTree page)
                            , navigationState = UI.State.Closed
                            }
                        , commands
                        )

                Wagtail.LoadPage (Err error) ->
                    Debug.log (toString error) (\x -> x)
                    ({ model | route = NotFoundRoute }, Cmd.none)


        NavigationMsg msg ->
            case msg of
                UI.State.FetchNavigation (Ok navigationTree) ->
                    ({ model | navigationTree = Just navigationTree }, Cmd.none)

                UI.State.FetchNavigation (Err error) ->
                    ({ model | navigationTree = Nothing }, Cmd.none)

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
                                ({ model | navigationState = newState }
                                , Maybe.withDefault Cmd.none command
                                )

                        _ ->
                            ({ model | navigationState = newState }, Cmd.none)



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
