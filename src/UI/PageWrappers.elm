module UI.PageWrappers exposing (..)

import Wagtail exposing (Page)
import Html.Styled exposing (..)
import Css exposing (..)
import UI.Case

import Html.Styled exposing (..)


renderPage : Page -> Html msg
renderPage page =
    case page of
        Wagtail.HomePage content ->
            div [] [ text "homepage" ]

        Wagtail.CasePage content ->
            UI.Case.view content




overlayWrapper : Html msg -> Html msg
overlayWrapper child =
    let
        wrapper =
            styled div
                [ zIndex (int 80)
                , position fixed
                , top zero
                , left zero
                , width (vw 100)
                , height (vh 100)
                , backgroundColor (hex "fff")
                ]

    in
        wrapper [] [ child ]


