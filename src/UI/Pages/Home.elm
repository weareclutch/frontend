module UI.Pages.Home exposing (view)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class, attribute, id, href)
import UI.Components.Blocks exposing (richText)
import UI.Components.CasePoster
import UI.Common exposing (button)
import Style exposing (..)
import Wagtail
import Types exposing (Msg)


view : Wagtail.HomePageContent -> Html Msg
view content =
    let
        innerWrapper =
            styled div
                [ width (pct 100)
                , maxWidth (px 1400)
                , margin auto
                , position relative
                ]


        (evenCases, oddCases) =
            content.cases
                |> List.reverse
                |> List.indexedMap (,)
                |> List.partition (\(index, x) -> index % 2 == 0)

        caseWrapper =
            styled div
                [ marginBottom (px 20)
                , bpMedium
                    [ marginBottom (px 80)
                    ]
                , bpLarge
                    [ marginBottom (px 120)
                    ]
                ]

        casesWrapper =
            styled div
                [ bpMedium
                    [ width <| calc (pct 50) minus (px 30)
                    ]
                , bpLarge
                    [ width <| calc (pct 50) minus (px 40)
                    ]
                , bpXLargeUp
                    [ width <| calc (pct 50) minus (px 60)
                    ]
                , nthChild "even"
                    [ bpMediumUp
                        [ position absolute
                        , top (px 350)
                        , right zero
                        ]
                    ]
                ]
    in
        div [ class "home" ] <|
            [ pageWrapper
                [ innerWrapper []
                    [ evenCases
                        |> List.map Tuple.second
                        |> List.map
                            (\x ->
                                caseWrapper [] [ UI.Components.CasePoster.view x ]
                            )
                        |> casesWrapper []
                    , oddCases
                        |> List.map Tuple.second
                        |> List.map
                            (\x ->
                                caseWrapper [] [ UI.Components.CasePoster.view x ]
                            )
                        |> casesWrapper []
                    ]
                ]
            , introCover content
            ]


pageWrapper : List (Html msg) -> Html msg
pageWrapper children =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , position relative
                , zIndex (int 10)
                , backgroundColor (hex "292A32")
                , padding4 (px 140) (px 25) (px 80) (px 25)
                , bpMedium
                    [ padding4 (px 280) (px 80) (px 140) (px 80)
                    ]
                , bpLarge
                    [ padding4 (px 280) (px 140) (px 140) (px 140)
                    ]
                , bpXLargeUp
                    [ padding4 (px 280) (px 240) (px 140) (px 240)
                    ]
                ]

        innerWrapper =
            styled div
                [ margin auto
                , padding4 zero zero (px 280) zero
                ]
    in
        wrapper []
            [ innerWrapper [] children
            ]


introCover : Wagtail.HomePageContent -> Html msg
introCover content =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , position relative
                , zIndex (int 5)
                ]

        title =
            styled div
                [ letterSpacing (px 2)
                , fontSize (px 22)
                , fontWeight (int 500)
                , marginBottom (px 6)
                ]

        textWrapper =
            styled div
                [ color (hex content.theme.textColor)
                , maxWidth (px 660)
                , margin auto
                , transform (translateY (pct -50))
                , top (pct 50)
                , left (pct 50)
                , position absolute
                ]

        lottiePlayer =
            styled div
                [ position relative
                , maxWidth (px 600)
                , maxHeight (px 600)
                , width (pct 100)
                , height (pct 100)
                , margin auto
                , top (pct 50)
                , transform <| translateY (pct -50)
                ]
    in
        wrapper []
            [ lottiePlayer
                [ attribute "data-anim-loop" "true"
                , attribute "data-animation-path" "animation/"
                , attribute "data-name" "loader"
                , id "home-animation"
                ]
                []
            , textWrapper [ ]
                [ title [] [ text "Uitgelicht" ]
                , richText content.cover.text
                , a [ href content.cover.link ]
                    [ UI.Common.button content.theme [] (Just "lees verder")
                    ]
                ]
            ]


