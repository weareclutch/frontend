module UI.Components.Contact exposing (view)

import Html.Styled exposing (..)
import Html.Styled.Attributes
import Css exposing (..)
import Style exposing (..)
import UI.State exposing (..)

view : Html msg
view =
    let
        outerWrapper =
            styled div
                [ width (vw 100)
                , height (vh 100)
                ]

        wrapper =
            styled div
                [ position relative
                , top (pct 50)
                , transform (translateY (pct -50))
                , color (hex "fff")
                , transition "opacity" 0.28 0.26 "ease-in-out"
                , maxWidth (px 1440)
                , margin auto
                , padding2 zero (px 25)
                , bpMedium
                    [ padding2 zero (px 80)
                    ]
                , bpLargeUp
                    [ padding2 zero (px 160)
                    ]
                ]


        link =
            styled a
                [ color (hex "00FFB0")
                , textDecoration none
                ]


        paragraph =
            styled p
                [ fontSize (px 48)
                , lineHeight (px 56)
                , letterSpacing (px 3.25)
                , fontFamilies [ "Qanelas ExtraBold" ]
                , bpMediumUp
                    [ ]
                ]


    in
        outerWrapper []
            [ wrapper []
                [ paragraph []
                    [ text "Mail ons op "
                    , link
                        [ Html.Styled.Attributes.href "mailto:info@weareclutch.nl" ]
                        [ text "info@weareclutch.nl" ]
                    , br [] []
                    , text "Bel ons via "
                    , link
                        [ Html.Styled.Attributes.href "phone:+31627333700" ]
                        [ text "06 27 333 700" ]
                    , br [] []
                    , link
                        [ Html.Styled.Attributes.href "https://www.instagram.com/clutch_amsterdam/"
                        , Html.Styled.Attributes.target "_blank"
                        ]
                        [ text "Volg ons" ]
                    , text " op instagram "
                    ]
                ]
            ]

