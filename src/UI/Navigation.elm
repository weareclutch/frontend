module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Events exposing (..)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (burger, cross)
import UI.Common exposing (addLink)


view : Model -> Html Msg
view model =
    let
        wrapper =
            styled div
                [ position absolute
                , zIndex (int 100)
                , top zero
                , left zero
                , width (pct 100)
                , backgroundColor (hex "0ff")
                ]

        toggleWrapper =
            styled div
                [ position absolute
                , right (px 100)
                , top (px 75)
                , zIndex (int 110)
                , cursor pointer
                , padding (px 8)
                ]

        burgerWrapper =
            styled div
                [ position absolute
                , top (px 12)
                , left (px 6)
                , property "transition" "opacity 0.2s linear"
                , opacity <|
                    int <|
                        if model.menuState == Closed && model.activeOverlay == Nothing then
                            1
                        else
                            0
                ]

        crossWrapper =
            styled div
                [ property "transition" "opacity 0.2s linear"
                , opacity <|
                    int <|
                        if model.menuState /= Closed || model.activeOverlay /= Nothing then
                            1
                        else
                            0
                ]

        logoWrapper =
            styled div
                [ position absolute
                , left (px 100)
                , top (px 80)
                , zIndex (int 110)
                , cursor pointer
                ]

        menuWrapper =
            (\menuState ->
                let
                    extraStyle =
                        case menuState of
                            Closed ->
                                [ opacity zero
                                , transform <| translateY (pct -100)
                                ]

                            _ ->
                                [ opacity (int 1)
                                , transform <| translateY (pct 0)
                                ]
                in
                    styled ul <|
                        [ listStyle none
                        , textAlign center
                        , position absolute
                        , width (pct 100)
                        , property "transition" "all 0.4s ease-in-out"
                        ]
                            ++ extraStyle
            )

        menuItem =
            styled li
                [ display inlineBlock
                , color (hex "fff")
                , margin2 zero (px 10)
                , fontSize (px 20)
                ]

        toggleAction =
            if model.activeOverlay == Nothing then
                [ onClick (ToggleMenu) ]
            else
                addLink "/"
    in
        wrapper []
            [ toggleWrapper toggleAction
                [ burgerWrapper [] [ burger ]
                , crossWrapper [] [ cross ]
                ]
            , menuWrapper model.menuState
                []
                [ menuItem [] [ text "Work" ]
                , menuItem [] [ text "Services" ]
                , menuItem [] [ text "Cultuur" ]
                , menuItem [] [ text "Blog" ]
                , menuItem [] [ text "Contact" ]
                ]
            , logoWrapper (addLink "/")
                [ logo
                ]
            ]
