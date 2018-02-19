module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import Html.Styled.Events exposing (..)


view : Html Msg
view =
    let
        wrapper =
            styled div
                [ position absolute
                , top zero
                , right zero
                , zIndex (int 100)
                ]

        toggle =
            styled div
                [ width (px 40)
                , height (px 40)
                , backgroundColor (hex "fa0")
                ]
    in
        wrapper []
            [ toggle [ onClick (ToggleMenu) ] []
            ]
