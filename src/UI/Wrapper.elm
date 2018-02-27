module UI.Wrapper exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Css.Foreign exposing (global, selector)
import Dict
import Style exposing (..)


globalStyle : Html msg
globalStyle =
    global
        [ selector "body"
            [ fontFamilies [ "Roboto", "sans-serif" ]
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
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , letterSpacing (px 8.4)
            , margin4 zero zero (px 35) zero
            , padding zero
            ]
        , selector "h2"
            [ fontSize (px 50)
            , lineHeight (px 60)
            , letterSpacing (px 3.5)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 35) zero
            , padding zero
            ]
        , selector "p"
            [ fontSize (px 22)
            , lineHeight (px 34)
            , fontFamilies [ "Roboto", "sans-serif" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 35) zero
            , padding zero
            , letterSpacing (px 2)
            ]
        ]


view : Model -> List (Html Msg) -> Html Msg
view model children =
    let
        maybePage =
            model.activePage
                |> Maybe.andThen
                    (\activePage ->
                        Dict.get activePage model.pages
                    )

        extraStyle =
            if maybePage /= Nothing || model.activeCase /= Nothing then
                [ opacity (int 1)
                ]
            else
                [ opacity zero
                ]

        wrapper =
            styled div <|
                [ backgroundColor (hex "292A32")
                , transition "all" 0.4 0 "ease-in-out"
                ]
                    ++ extraStyle
    in
        globalStyle
            :: children
            |> wrapper []
