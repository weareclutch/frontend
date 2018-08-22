module UI.Contact exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Style exposing (..)
import UI.State exposing (MenuState(OpenBottomContact, OpenTopContact))

view : Model -> Html msg
view model =
    let
        active =
            case model.menuState of
                OpenTopContact ->
                    True

                OpenBottomContact ->
                    True

                _ ->
                    False


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
                , padding2 zero (px 25)
                , bpMedium
                    [ padding2 zero (px 80)
                    ]
                , bpLargeUp
                    [ padding2 zero (px 160)
                    ]
                , zIndex <|
                    if active then
                        (int 140)
                    else
                        (int 0)
                , opacity <|
                    if active then
                        (int 1)
                    else
                        (int 0)
                ]

        title =
            styled h2
                [ fontSize (px 28)
                , lineHeight (px 32)
                , bpMedium
                    [ fontSize (px 50)
                    , lineHeight (px 60)
                    ]
                , bpLargeUp
                    [ fontSize (px 96)
                    , lineHeight (px 112)
                    ]
                ]

        paragraph =
            styled p
                [ fontSize (px 22)
                , lineHeight (px 34)
                , bpMediumUp
                    [ fontSize (px 26)
                    , lineHeight (px 40)
                    ]
                ]

    in
        outerWrapper []
            [ wrapper []
                [ title [] [ text "Afspreken? Leuk!" ]
                , paragraph []
                    [ text "info@weareclutch.nl"
                    , br [] []
                    , text "06 27 333 700"
                    , br [] []
                    , text "Barentszplein 4F"
                    , br [] []
                    , text "1052 NA, Amsterdam"
                    ]
                ]
            ]

