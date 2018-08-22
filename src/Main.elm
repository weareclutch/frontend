module Main exposing (..)

import Navigation exposing (Location)
import Html.Styled exposing (..)
import UI.Wrapper
import UI.Navigation
import UI.Page
import Wagtail exposing (getWagtailPage)
import UI.State exposing (MenuState(..))

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
        command = getAndDecodePage location
    in
        ( initModel , command )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- LoadPage (Ok page) ->
        --     Debug.log (toString page) (\x -> x)
        --     (model, Cmd.none)

        -- LoadPage (Err error) ->
        --     Debug.log (toString error) (\x -> x)
        --     (model, Cmd.none)

        OnLocationChange location ->
            (model, getAndDecodePage location)

        ChangeLocation path ->
            (model, Navigation.newUrl path)

        NavigationMsg UI.State.ToggleMenu ->
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

        NavigationMsg UI.State.OpenContact ->
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


        NavigationMsg (UI.State.OpenMenu state) ->
            ( { model | menuState = state }, Cmd.none )

        -- OpenService service ->
        --     ( { model | activeService = Just service }, Cmd.none )

        -- CloseService ->
        --     ( { model | activeService = Nothing }, Cmd.none )

        _ -> (model, Cmd.none)


view : Model -> Html Msg
view model =
    UI.Wrapper.view model
        [ UI.Navigation.view model.menuState
        , UI.Page.container model
        -- , UI.Case.staticView model
        -- , UI.Pages.Services.overlay model.activeService
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
