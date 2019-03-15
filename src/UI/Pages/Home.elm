module UI.Pages.Home exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, class, href, id, src, autoplay, loop)
import Html.Styled.Events exposing (onClick)
import Style exposing (..)
import Types exposing (Msg(..))
import UI.Common exposing (backgroundImg, button, siteMargins, container)
import UI.Components.Blocks exposing (richText)
import UI.Components.CasePoster
import Wagtail
import Regex


view : Wagtail.HomePageContent -> Html Msg
view content =
    let
        ( evenCases, oddCases ) =
            content.cases
                |> List.reverse
                |> List.indexedMap (\x y -> (x, y))
                |> List.partition (\( index, x ) -> (remainderBy 2 index) == 0)

        caseWrapper =
            styled div
                [ marginBottom (px 25)
                , position relative
                , textAlign left
                , zIndex (int 80)
                , bpMedium
                    [ marginBottom (px 25)
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
                    [ position relative
                    , bpMediumUp
                        [ display inlineBlock
                        ]
                    ]
                , nthChild "odd"
                    [ position relative
                    , bpMediumUp
                        [ position absolute
                        , left zero
                        ]
                    , bpMedium
                        [ top (px 50)
                        ]
                    , bpLarge
                        [ top (px 80)
                        ]
                    , bpXLargeUp
                        [ top (px 160)
                        ]
                    ]
                ]

        casesOuterWrapper =
            styled div
                [ backgroundColor (hex "292A32")
                , padding4 (px 240) zero zero zero
                , textAlign right
                , marginBottom (px -50)
                , bpMediumUp
                    [ padding2 (px 240) zero
                    , margin zero
                    ]
                ]
    in
    div [ id "home" ] <|
        [ casesOuterWrapper []
            [ container []
                [ siteMargins []
                    [ oddCases
                        |> List.map Tuple.second
                        |> List.map
                            (\x ->
                                caseWrapper [] [ UI.Components.CasePoster.view x ]
                            )
                        |> casesWrapper []
                    , evenCases
                        |> List.map Tuple.second
                        |> List.map
                            (\x ->
                                caseWrapper [] [ UI.Components.CasePoster.view x ]
                            )
                        |> casesWrapper []
                    ]
                ]
            ]
        , introCover content
        ]


introCover : Wagtail.HomePageContent -> Html Msg
introCover content =
    let
        activeLogo =
            List.head content.logos

        bgColor =
            Maybe.map (\l -> l.theme.backgroundColor) activeLogo
                |> Maybe.withDefault "fff"

        textColor =
            Maybe.map (\l -> l.theme.textColor) activeLogo
                |> Maybe.withDefault "000"

        imageWrapper =
            styled div
                [ position absolute
                , cursor pointer
                , maxWidth (px 560)
                , width (pct 82)
                , maxWidth (px 420)
                , height (pct 80)
                , left (pct 50)
                , transform <| translateX (pct -50)
                , bottom zero
                , backgroundSize contain
                , backgroundPosition top
                , zIndex (int 0)
                , bpMediumUp
                    [ transform (translate2 (pct -100) (pct -50))
                    , top (pct 50)
                    , bottom auto
                    , backgroundPosition center
                    , left <| calc (pct 50) plus (px 120)
                    , maxWidth (px 720)
                    , width (pct 50)
                    , height (pct 100)
                    ]
                ]

        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex bgColor)
                , position relative
                , zIndex (int 5)
                , bpMedium
                    [ marginTop (px -300)
                    ]
                , bpLarge
                    [ marginTop (px -340)
                    ]
                , bpXLargeUp
                    [ marginTop (px -400)
                    ]
                , before
                    [ property "content" "''"
                    , display block
                    , position absolute
                    , top (px -230)
                    , left zero
                    , height (px 230)
                    , width (pct 100)
                    , zIndex (int 20)
                    , backgroundImage
                        <| linearGradient
                            (stop (rgba 0 0 0 0.0))
                            (stop (hex bgColor))
                            []
                    ]
                ]

        textWrapper =
            styled div
                [ margin auto
                , color (hex textColor)
                , maxWidth (px 420)
                , width (pct 100)
                , padding2 zero (px 25)
                , position absolute
                , bottom (px 120)
                , zIndex (int 2)
                , left (pct 50)
                , transform (translateX (pct -50))
                , textAlign center
                , bpMediumUp
                    [ position absolute
                    , transform (translateY (pct -50))
                    , top (pct 50)
                    , bottom auto
                    , textAlign left
                    , left (pct 50)
                    ]
                , bpMedium
                    [ padding4 zero (px 40) zero zero
                    , maxWidth (vw 40)
                    ]
                , bpLarge
                    [ padding4 zero (px 120) zero zero
                    , maxWidth (px 620)
                    ]
                , bpXLargeUp
                    [ padding4 zero (px 120) zero zero
                    , maxWidth (px 820)
                    ]
                ]

        title =
            styled h4
                [ margin zero
                ]

        refreshButton =
            styled div
                [ display inlineBlock
                , cursor pointer
                , height (px 60)
                , width (px 60)
                , textAlign center
                , backgroundColor (hex bgColor)
                , border zero
                , borderRadius (pct 50)
                , paddingTop (px 18)
                , transition "box-shadow" 0.16 0 "linear"
                , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.25)
                , hover
                    [ boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.45)
                    ]
                ]

        author =
            styled p
                [ display inlineBlock
                , color (hex textColor)
                , property "opacity" "0.2"
                , margin4 zero (px 20) zero zero
                , fontSize (px 14)
                , fontWeight (int 500)
                ]

        logoInfo =
            styled div
                [ position absolute
                , bottom zero
                , width (pct 100)
                , textAlign center
                , padding (px 32)
                , bpMediumUp
                    [ textAlign right
                    ]
                ]

    in
        wrapper []
            [ textWrapper []
                  [ title [] [ text content.text ]
                  ]
            , activeLogo
                |> Maybe.map
                    (\l ->
                      imageWrapper
                         [ onClick <| SpinLogos <| (List.length content.logos - 1)
                         , backgroundImg l.image
                         ]
                         []
                    )
                |> Maybe.withDefault (text "")
            , activeLogo
                |> Maybe.map
                   (\logo ->
                      logoInfo []
                        [ author [ ] [ text <| "ontworpen door " ++ logo.author ]
                        ]
                   )
                |> Maybe.withDefault (text "")
              ]
