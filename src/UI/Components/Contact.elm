module UI.Components.Contact exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes
import Style exposing (..)
import UI.State exposing (ContactInformation)


view : ContactInformation -> Html msg
view contactInfo =
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
                [ color (hex "fff")
                , textDecoration none
                ]

        paragraph =
            styled p
                [ fontSize (px 24)
                , lineHeight (px 40)
                , letterSpacing (px 1.29)
                , maxWidth (px 260)
                , fontWeight (int 700)
                , bpMediumUp
                    []
                ]

        title =
            styled h3
                [ fontSize (px 80)
                , marginBottom (px 30)
                ]
    in
    outerWrapper []
        [ wrapper []
            [ title [] [ text "contact" ]
            , paragraph []
                [ link
                    [ Html.Styled.Attributes.href ("mailto:" ++ contactInfo.email) ]
                    [ text contactInfo.email ]
                , br [] []
                , link
                    [ Html.Styled.Attributes.href ("phone:" ++ contactInfo.phone) ]
                    [ text contactInfo.phone ]
                , br [] []
                , br [] []
                , text contactInfo.address
                ]
            ]
        ]
