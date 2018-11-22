module UI.Pages.Home exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, class, href, id)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (backgroundImg, button)
import UI.Components.Blocks exposing (richText)
import UI.Components.CasePoster
import Wagtail


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

        ( evenCases, oddCases ) =
            content.cases
                |> List.reverse
                |> List.indexedMap (,)
                |> List.partition (\( index, x ) -> index % 2 == 0)

        caseWrapper =
            styled div
                [ marginBottom (px 20)
                , bpMedium
                    [ marginBottom (px 20)
                    ]
                , bpLarge
                    [ marginBottom (px 50)
                    ]
                , bpXLargeUp
                    [ marginBottom (px 120)
                    ]
                ]

        casesWrapper =
            styled div
                [ bpMedium
                    [ width <| calc (pct 50) minus (px 10)
                    ]
                , bpLarge
                    [ width <| calc (pct 50) minus (px 25)
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
    div [] <|
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
                    [ padding4 (px 280) (px 25) (px 140) (px 25)
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
                , overflow hidden
                ]

        title =
            styled div
                [ marginBottom (px 6)
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

        imageDiv =
            styled div
                [ position absolute
                , maxHeight (px 700)
                , maxWidth (px 700)
                , height (vw 40)
                , width (vw 40)
                , top (pct 50)
                , left <| calc (pct 50) minus (vw 20)
                , transform <| translate2 (pct -50) (pct -50)
                , backgroundSize cover
                , backgroundPosition center
                ]

        image =
            case content.cover.image of
                Just img ->
                    imageDiv [ backgroundImg img ] []

                Nothing ->
                    text ""
    in
    wrapper []
        [ image
        , textWrapper []
            [ title [] [ text "Uitgelicht" ]
            , richText content.cover.text
            , a [ href content.cover.link ]
                [ UI.Common.button content.theme [] (Just "lees verder")
                ]
            ]
        ]
