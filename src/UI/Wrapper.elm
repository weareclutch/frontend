module UI.Wrapper exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Css.Foreign exposing (global, selector)


globalStyle : Html msg
globalStyle =
    global
        [ selector "body"
            [ fontFamilies [ "sans-serif" ]
            , margin zero
            , padding zero
            , overflow hidden
            , height (vh 100)
            , width (vw 100)
            , border3 (px 1) solid (hex "f00")
            ]
        , selector "html"
            [ boxSizing borderBox
            ]
        , selector "*, *:before, *:after"
            [ boxSizing borderBox
            ]
        , selector "h1"
            [ fontSize (px 120)
            , lineHeight (px 130)
            , fontFamilies ["Qanelas ExtraBold"]
            ]
        , selector "h2"
            [ fontSize (px 50)
            , lineHeight (px 60)
            , fontFamilies ["Qanelas ExtraBold"]
            ]
        , selector "p"
            [ fontSize (px 22)
            , lineHeight (px 34)
            , fontFamilies ["Roboto", "sans-serif"]
            , fontWeight (int 500)
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
