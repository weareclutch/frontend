module UI.PageWrappers exposing (..)

import Wagtail exposing (Page)
import Html.Styled exposing (..)
import Css exposing (..)
import UI.Pages.Case
import UI.Pages.Home
import Types exposing (Msg)


renderPage : Page -> Html Msg
renderPage page =
    case page of
        Wagtail.HomePage content ->
            UI.Pages.Home.view content

        Wagtail.CasePage content ->
            UI.Pages.Case.view content


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
                , overflowY scroll
                ]

    in
        wrapper [] [ child ]


