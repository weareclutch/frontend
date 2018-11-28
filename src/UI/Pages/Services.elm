module UI.Pages.Services exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Attributes exposing (class)
import Types exposing (..)
import Wagtail
import UI.Common exposing (slideshow, backgroundImg, loremIpsum, siteMargins)


view : Wagtail.ServicesContent -> Html Msg
view content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                , padding2 (pct 20) zero
                ]


        title =
            styled h1
                [ color (hex "001AE0")
                ]


    in
    wrapper []
        [ siteMargins []
            [ title [] [ text content.title ]
            , p [ class "intro" ] [ text content.introduction ]
            ]

        , slideshow
            "services-slideshow"
            (1, 1, 1)
            slideImage
            content.images
        ]


slideImage : Wagtail.Image -> Html msg
slideImage image =
    let
        wrapper =
            styled div
                [ paddingTop (pct 40)
                , width (pct 100)
                , backgroundSize cover
                , backgroundPosition center
                ]

    in
        wrapper [ backgroundImg image ] []


