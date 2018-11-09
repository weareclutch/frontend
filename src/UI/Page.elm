module UI.Page exposing (container)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class)
import Html.Styled.Events exposing (..)
import Json.Decode as Json
import Types exposing (..)
import UI.Contact
import UI.State exposing (MenuState(..), Msg)


containerWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
containerWrapper =
    styled div <|
        [ backgroundColor (hex "001AE0")
        , height (vh 100)
        , width (vw 100)
        , position absolute
        , top zero
        , left zero
        ]


pageOrder : List String
pageOrder =
    [ "service.ServicesPage"
    , "home.HomePage"

    -- , "culture.CulturePage"
    ]


container : Model -> Html Types.Msg
container model =
    let
        activeDepth =
            0

        pages =
            pageOrder
                |> List.indexedMap
                    (\index pageType ->
                        let
                            depth =
                                if index <= activeDepth then
                                    index - activeDepth

                                else
                                    index - activeDepth - List.length pageOrder
                        in
                        pageView model pageType depth
                    )
    in
    containerWrapper [] <|
        pages
            ++ [ UI.Contact.view model ]


pageWrapper : Int -> Bool -> MenuState -> List (Attribute msg) -> List (Html msg) -> Html msg
pageWrapper depth locked menuState =
    let
        lockStyle =
            if locked then
                overflowY hidden

            else
                overflowY scroll

        transformStyle =
            case menuState of
                Closed ->
                    [ transforms [] ]

                OpenTop ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 140 * depth + 300)
                        , scale <| 0.1 * toFloat depth + 0.94
                        ]
                    ]

                OpenTopContact ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 140 * depth + 900)
                        , scale <| 0.1 * toFloat depth + 0.94
                        ]
                    ]

                OpenBottom ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| -140 * depth - 300)
                        , scale <| 0.1 * toFloat depth + 0.94
                        ]
                    ]

                OpenBottomContact ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| -140 * depth - 900)
                        , scale <| 0.1 * toFloat depth + 0.94
                        ]
                    ]

        extraStyles =
            lockStyle
                :: transformStyle
                ++ [ property "-webkit-overflow-scrolling" "touch"
                   , pseudoElement "-webkit-scrollbar"
                        [ display none
                        ]
                   , property "-ms-overflow-style" "none"
                   , overflowX hidden
                   ]
    in
    styled div <|
        [ backgroundColor (hex "292A32")
        , boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
        , height (vh 100)
        , width (vw 100)
        , position absolute
        , top zero
        , left zero
        , zIndex (int <| 10 + depth)
        , property "transition" "all 0.28s ease-in-out"
        , if menuState == Closed then
            cursor default

          else
            cursor pointer
        ]
            ++ extraStyles


handleScroll : Json.Decoder Float
handleScroll =
    Json.at [ "target", "scrollTop" ] Json.float


pageView : Model -> String -> Int -> Html Types.Msg
pageView model pageType depth =
    let
        locked =
            False

        -- (model.activeCase
        --     |> Maybe.map (\activeCase -> True)
        --     |> Maybe.withDefault False
        -- )
        --     || (model.menuState == OpenTop || model.menuState == OpenBottom)
        pageTypeClassName =
            String.split "." pageType
                |> List.head
                |> Maybe.withDefault ""

        isActive =
            False

        -- model.activePage
        --     |> Maybe.andThen
        --         (\activePage ->
        --             if activePage == pageType then
        --                 Just True
        --             else
        --                 Nothing
        --         )
        --     |> Maybe.withDefault False
        action =
            if isActive then
                [ onClick <| NavigationMsg <| UI.State.OpenMenu UI.State.Closed
                ]

            else
                []

        className =
            if isActive then
                "page-wrapper active"

            else
                "page-wrapper"

        attributes =
            [ class <| className ++ " " ++ pageTypeClassName

            -- , on "scroll" (Json.map (ScrollEvent pageType) handleScroll)
            ]
                ++ action

        page =
            text ""

        --model.pages
        --    |> Dict.get pageType
        --    |> Maybe.andThen
        --        (\page ->
        --            case page of
        --                Home content ->
        --                    Just <| UI.Pages.Home.view model content
        --                Services content ->
        --                    Just <| UI.Pages.Services.view content
        --                Culture content ->
        --                    Just <| UI.Pages.Culture.view model content
        --                _ ->
        --                    Nothing
        --        )
        --    |> Maybe.withDefault (text "")
    in
    pageWrapper depth
        locked
        model.menuState
        attributes
        [ page
        ]
