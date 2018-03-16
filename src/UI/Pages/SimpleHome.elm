module UI.Pages.SimpleHome exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import UI.Common exposing (button, backgroundImg)
import Html.Styled.Events exposing (onClick)


easterEgg : List (String, Image) -> Html Msg
easterEgg list =
    List.head list
        |> Maybe.map
            (\(color, image) ->
                let
                    wrapper =
                        styled div
                            [ height (vh 100)
                            , width (vw 100)
                            , backgroundColor (hex color)
                            ]

                    imageWrapper =
                        styled div
                            [ maxWidth (px 800)
                            , maxHeight (px 800)
                            , width (pct 100)
                            , height (pct 100)
                            , position absolute
                            , top (pct 50)
                            , left (pct 50)
                            , transforms
                                [ translateY (pct -50)
                                , translateX (pct -50)
                                ]
                            ]

                    buttonWrapper =
                        styled div
                            [ position absolute
                            , bottom (px 80)
                            , textAlign center
                            , width (pct 100)
                            ]

                in
                    wrapper []
                        [ imageWrapper [ backgroundImg image ] []
                        , buttonWrapper []
                            [ UI.Common.button
                                { backgroundColor = color, textColor = "fff", backgroundPosition = Nothing }
                                [ onClick <| SpinEasterEgg 0 6 ]
                                (Just "spin")
                            ]
                        ]
            )
        |> Maybe.withDefault (text "")


view : Model -> HomeContent -> Html Msg
view model content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                ]
    in
        wrapper []
            [ easterEgg content.easterEggImages
            ]