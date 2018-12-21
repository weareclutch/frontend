module UI.Pages.Home exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, class, href, id, src, autoplay, loop)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (link, backgroundImg, button, siteMargins, container)
import UI.Components.Blocks exposing (richText)
import UI.Components.CasePoster
import Wagtail


view : Wagtail.HomePageContent -> Html Msg
view content =
    let
        ( evenCases, oddCases ) =
            content.cases
                |> List.reverse
                |> List.indexedMap (,)
                |> List.partition (\( index, x ) -> index % 2 == 0)

        caseWrapper =
            styled div
                [ marginBottom (px 25)
                , position relative
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
                , nthChild "odd"
                    [ position relative
                    , top (px -120)
                    ]
                , nthChild "even"
                    [ bpMediumUp
                        [ position absolute
                        , right zero
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
                , marginBottom (px -50)
                , paddingTop (px 240)
                , bpMediumUp
                    [ paddingTop (px 240)
                    , margin zero
                    ]
                ]
    in
    div [] <|
        [ casesOuterWrapper []
            [ container []
                [ siteMargins []
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
            ]
        , introCover content
        ]


introCover : Wagtail.HomePageContent -> Html Msg
introCover content =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , position relative
                , zIndex (int 5)
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
                            (stop (hex "292A32"))
                            (stop (rgba 0 0 0 0.0))
                            []
                    ]
                ]

        title =
            styled div
                [ marginBottom (px 6)
                , display none
                , bpMediumUp
                    [ display block
                    ]
                ]

        textWrapper =
            styled div
                [ color (hex content.theme.textColor)
                , margin auto
                , maxWidth (px 420)
                , padding2 zero (px 25)
                , position absolute
                , bottom (px 140)
                , textAlign center
                , bpMediumUp
                    [ position absolute
                    , transform (translateY (pct -50))
                    , padding zero
                    , top (pct 50)
                    , bottom auto
                    , textAlign left
                    , maxWidth (px 560)
                    , left (pct 50)
                    ]
                ]

        mediaWrapper =
            styled div
                [ overflow hidden
                , height <| calc (vh 100) plus (px 230)
                , width (vw 100)
                , position absolute
                , bottom zero
                ]

        videoDiv =
            styled div
                [ height (pct 200)
                , width (px 1280)
                , top (pct 50)
                , left (pct 50)
                , transform <| translate2 (pct -50) (pct -50)
                , position absolute
                , bpMediumUp
                    [ height (pct 200)
                    , width (pct 200)
                    , top <| calc (pct 50) plus (px 120)
                    , left <| calc (pct 50) minus (px 300)
                    , transform <| translate2 (pct -50) (pct -50)
                    ]
                ]

        videoEl =
            styled video
                [ width (pct 100)
                , height (pct 100)
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

        media =
            content.cover.media
                |> Debug.log "media"
                |> Maybe.andThen
                    (\media ->
                        case media of
                            Wagtail.ImageMedia img ->
                                Just <| imageDiv [ backgroundImg img ] []

                            Wagtail.VideoMedia url ->
                                Just <| videoDiv []
                                    [ videoEl
                                        [ src url
                                        , autoplay True
                                        , loop True
                                        , attribute "muted" ""
                                        , attribute "playsinline" ""
                                        ]
                                        [ source
                                            [ src url
                                            ]
                                            []
                                        ]
                                    ]

                            _ ->
                                Nothing

                    )
                |> Maybe.map (\el -> mediaWrapper [] [ el ])
                |> Maybe.withDefault (text "")

    in
    wrapper []
        [ media
        , textWrapper []
            [ title [] [ text "Uitgelicht" ]
            , richText content.cover.text
            , UI.Common.link content.cover.link
                [ UI.Common.button content.theme [] (Just "lees blog")
                ]
            ]
        ]
