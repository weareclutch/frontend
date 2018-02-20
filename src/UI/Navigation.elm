module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Events exposing (..)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (menuToggle)
import UI.Common exposing (addLink)


view : Model -> Html Msg
view model =
    let
        wrapper =
            styled div
                [ position absolute
                , zIndex (int 100)
                , top zero
                , width (pct 100)
                ]

        innerWrapper =
            styled div
                [ maxWidth (px 1280)
                , margin4 (px 40) auto zero auto
                , position relative
                ]

        toggleWrapper =
            styled div
                [ position absolute
                , right zero
                , top zero
                , padding2 (px 12) (px 8)
                , zIndex (int 110)
                , cursor pointer
                ]

        logoWrapper =
            styled div
                [ position absolute
                , left zero
                , top zero
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
    in
        wrapper []
            [ innerWrapper []
                [ toggleWrapper [ onClick (ToggleMenu) ]
                    [ menuToggle model.menuState
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
            ]
