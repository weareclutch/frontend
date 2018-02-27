module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class, attribute, id, href)
import UI.Case
import UI.Blocks exposing (richText)
import UI.Common exposing (button)
import Dict
import Style exposing (..)


view : Model -> HomeContent -> Html Msg
view model content =
    let
        pageScroll =
            model.pageScrollPositions
                |> Dict.get "home.HomePage"
                |> Maybe.withDefault 0

        indexedCases =
            content.cases
                |> List.indexedMap
                    (\index page ->
                        model.activeOverlay
                            |> Maybe.andThen (\id -> Just (id == page.meta.id))
                            |> Maybe.withDefault False
                            |> UI.Case.overlay model (List.drop index content.cases)
                            |> (,) index
                    )
                |> List.reverse

        innerWrapper =
            styled div
                [ width (pct 100)
                , maxWidth (px 1400)
                , margin auto
                , position relative
                ]

        caseWrapper =
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
                    [ indexedCases
                        |> List.filter
                            (\( index, page ) ->
                                index % 2 /= 0
                            )
                        |> List.map Tuple.second
                        |> caseWrapper []
                    , indexedCases
                        |> List.filter
                            (\( index, page ) ->
                                index % 2 == 0
                            )
                        |> List.map Tuple.second
                        |> caseWrapper []
                    ]
                ]
            , introCover pageScroll content
            ]


pageWrapper : List (Html Msg) -> Html Msg
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


introCover : Float -> HomeContent -> Html msg
introCover offset content =
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
            , textWrapper []
                [ title [] [ text "Uitgelicht" ]
                , richText content.cover.text
                , a [ href content.cover.link ]
                    [ UI.Common.button content.theme [] (Just "lees verder")
                    ]
                ]
            ]
