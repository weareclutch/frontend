module UI.Page exposing (container)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Pages.Home
import UI.Pages.Services
import Dict


containerWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
containerWrapper =
    styled div <|
        [ backgroundColor (hex "f5f5f5")
        , height (vh 100)
        , width (vw 100)
        , position absolute
        , top zero
        , left zero
        ]


container : Model -> Html Msg
container model =
    containerWrapper []
        [ pageView model
            (if model.activePage == Home then
                0
             else
                -1
            )
            Home
        , pageView model
            (if model.activePage == Services then
                0
             else
                -1
            )
            Services
        ]


pageWrapper : Int -> Bool -> Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
pageWrapper depth locked menuActive =
    let
        lockStyle =
            if locked then
                overflow hidden
            else
                overflow auto

        transformStyle =
            if menuActive then
                [ transforms
                    [ translate2
                        (px 0)
                        (px <| toFloat <| 100 * depth + 100)
                    , scale <| 0.1 * (toFloat depth) + 0.94
                    ]
                ]
            else
                [ transforms [] ]

        extraStyles =
            lockStyle :: transformStyle ++ []
    in
        styled div <|
            [ backgroundColor (hex "fff")
            , boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
            , height (vh 100)
            , width (vw 100)
            , position absolute
            , top zero
            , left zero
            , zIndex (int <| 10 + depth)
            , property "transition" "all 0.28s ease-in-out"
            ]
                ++ extraStyles


pageView : Model -> Int -> PageType -> Html Msg
pageView model depth pageType =
    let
        locked =
            model.activeCase
                |> Maybe.map (\activeCase -> True)
                |> Maybe.withDefault False

        page =
            case pageType of
                Home ->
                    model.pages
                        |> Dict.get (toString Home)
                        |> UI.Pages.Home.view model

                Services ->
                    model.pages
                        |> Dict.get (toString Services)
                        |> UI.Pages.Services.view

                _ ->
                    text "unknown type"
    in
        pageWrapper depth locked model.menuActive [] [ page ]
