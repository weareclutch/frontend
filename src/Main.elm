module Main exposing (..)

import Navigation exposing (Location)
import Html.Styled exposing (..)
import UI.Wrapper
import Wagtail exposing (getWagtailPage, preloadWagtailPage)
import UI.State exposing (fetchNavigation)

import Types exposing (..)



initModel : Model
initModel =
    { route = UndefinedRoute
    , navigationState = UI.State.Closed
    , navigationTree = Nothing
    }


getAndDecodePage : Location -> Cmd Msg
getAndDecodePage location =
    getWagtailPage location
      |> Cmd.map (\cmd -> WagtailMsg cmd)


init : Location -> ( Model, Cmd Msg )
init location =
    let
        commands =
            [ getAndDecodePage location
            , fetchNavigation |> Cmd.map (\cmd -> NavigationMsg cmd)
            ]
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
                    ( { model
                        | route = WagtailRoute page
                        , navigationTree =
                            model.navigationTree
                            |> Maybe.map (UI.State.addPageToNavigationTree page)
                        , navigationState = UI.State.Closed
                        }
                    , Cmd.none
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
