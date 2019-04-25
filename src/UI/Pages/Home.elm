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
        caseWrapper =
            styled div
                [ position relative
                , textAlign left
                , zIndex (int 80)
                , whiteSpace normal
                , height (vw 100)
                , display block
                , bpMediumUp
                    [ width (vh 70)
                    , height (vh 100)
                    , display inlineBlock
                    ]
                ]

        casesWrapper =
            styled div
                [ display block
                , bpMediumUp
                  [ display inlineBlock
                  ]

                ]

        wrapper =
            styled div
                [ backgroundColor (hex "292A32")
                , property "-webkit-overflow-scrolling" "touch"
                , bpMediumUp
                    [ overflowX scroll
                    , overflowY hidden
                    , whiteSpace noWrap
                    , height (pct 100)
                    ]
                ]

    in
    wrapper [ id "home" ] <|
        [ introCover content
        , casesWrapper []
            <| List.map
                (\x ->
                    caseWrapper [] [ UI.Components.CasePoster.view x ]
                )
                content.cases
        ]


introCover : Wagtail.HomePageContent -> Html Msg
introCover content =
    content.logos
        |> List.head
        |> Maybe.map
            (\activeLogo ->
                let
                    bgColor =
                        activeLogo.theme.backgroundColor

                    textColor =
                        activeLogo.theme.textColor

                    imageWrapper =
                        styled div
                            [ position absolute
                            , cursor pointer
                            , maxWidth (px 560)
                            , width (pct 82)
                            , maxWidth (px 420)
                            , height (pct 92)
                            , left (pct 50)
                            , transform <| translateX (pct -50)
                            , bottom zero
                            , backgroundSize contain
                            , backgroundPosition top
                            , zIndex (int 0)
                            , bpLargeUp
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
                            , whiteSpace normal
                            , display block
                            , zIndex (int 5)
                            , bpMediumUp
                                [ display inlineBlock
                                , width <| calc (vw 100) minus (px 80)
                                ]
                            , before
                                [ property "content" "''"
                                , display none
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
                            , bpLargeUp
                                [ position absolute
                                , transform (translateY (pct -50))
                                , top (pct 50)
                                , bottom auto
                                , textAlign left
                                , left (pct 50)
                                ]
                            , bpLarge
                                [ padding4 zero (px 120) zero zero
                                , maxWidth (px 560)
                                ]
                            , bpXLargeUp
                                [ padding4 zero (px 120) zero zero
                                , maxWidth (px 620)
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
                            , bpLargeUp
                                [ textAlign left
                                ]
                            ]

                    casesTitle =
                        styled p
                            [ position absolute
                            , right zero
                            , bottom (px 120)
                            , transform <| rotate (deg -90)
                            , display none
                            , color (hex "fff")
                            , cursor pointer
                            , bpMediumUp
                                [ display block
                                ]
                            ]

                in
                    wrapper []
                        [ textWrapper []
                              [ richText content.text
                              , a [ href content.link.url ]
                                  [ button activeLogo.theme [] (Just content.link.title)
                                  ]
                              ]
                        , imageWrapper
                            [ onClick <| SpinLogos <| (List.length content.logos - 1)
                            , backgroundImg activeLogo.image
                            ]
                            []
                        , logoInfo []
                            [ author [ ] [ text <| "ontworpen door " ++ activeLogo.author ]
                            ]
                        , casesTitle
                              [ class "nav"
                              , onClick ScrollToCases
                              ]
                              [ text "ons werk" ]
                        ]
          )
      |> Maybe.withDefault (text "")
