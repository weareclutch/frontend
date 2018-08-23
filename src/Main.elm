module Main exposing (..)

import Navigation exposing (Location)
import Html.Styled exposing (..)
import UI.Wrapper
import UI.Navigation
-- import UI.Page
import UI.PageWrappers
import Wagtail exposing (getWagtailPage)
import UI.State exposing (MenuState(..), fetchNavigation)

import Types exposing (..)

-- getPageCommand : Model -> Page -> Cmd Msg
-- getPageCommand model page =
--     case page of
--         Home content ->
--             if (Dict.get content.pageType model.pages == Nothing) then
--                 content.animation
--                     |> Maybe.map
--                         (Regex.replace
--                             Regex.All
--                             (Regex.regex "http://localhost")
--                             (\_ -> siteUrl)
--                         )
--                     |> Ports.showHomeIntro
--             else
--                 Cmd.none
-- 
--         _ ->
--             Cmd.none



initModel : Model
initModel =
    { route = UndefinedRoute
    -- , pages = Dict.empty
    -- , activePage = Nothing
    -- , cases = Dict.empty
    -- , activeCase = Nothing
    -- , activeOverlay = Nothing
    -- , activeService = Nothing
    -- , casePosition = ( 0, 0 )
    , menuState = Closed
    , navigationTree = Nothing
    -- , pageScrollPositions = Dict.empty
    -- , parallaxPositions = Dict.empty
    -- , windowDimensions = ( 0, 0 )
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
                Wagtail.LoadPage (Ok page) ->
                    ({ model | route = WagtailRoute page }, Cmd.none )

                Wagtail.LoadPage (Err error) ->
                    Debug.log (toString error) (\x -> x)
                    ({ model | route = NotFoundRoute }, Cmd.none)


        NavigationMsg msg ->
            case msg of
                UI.State.FetchNavigation (Ok navigationTree) ->
                    ({ model | navigationTree = Just navigationTree }, Cmd.none)

                UI.State.FetchNavigation (Err error) ->
                    ({ model | navigationTree = Nothing }, Cmd.none)

                UI.State.ToggleMenu ->
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

                UI.State.OpenContact ->
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


                (UI.State.OpenMenu state) ->
                    ( { model | menuState = state }, Cmd.none )




        -- OpenService service ->
        --     ( { model | activeService = Just service }, Cmd.none )

        -- CloseService ->
        --     ( { model | activeService = Nothing }, Cmd.none )

        -- _ -> (model, Cmd.none)


view : Model -> Html Msg
view model =
    let
        page =
            case model.route of
                UndefinedRoute ->
                    div [] [ text "undefined route" ]

                WagtailRoute page -> 
                    UI.PageWrappers.renderPage page

                NotFoundRoute ->
                    div [] [ text "not found" ]

    in
        UI.Wrapper.view model
            [ UI.Navigation.view model.menuState
            , UI.PageWrappers.overlayWrapper page
            ]


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
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
