module UI.Wrapper exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import Css.Foreign exposing (global, selector)


globalStyle : Html msg
globalStyle =
    global
        [ selector "body"
            [ fontFamilies [ "sans-serif" ]
            , margin zero
            ]
        , selector "html"
            [ boxSizing borderBox
            ]
        , selector "*, *:before, *:after"
            [ boxSizing borderBox
            ]
        ]


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ backgroundColor (hex "fff")
        ]


view : Model -> List (Html Msg) -> Html Msg
view model children =
    globalStyle
        :: children
        |> wrapper []
