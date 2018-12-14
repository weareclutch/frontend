module UI.Pages.Home exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, class, href, id, src, autoplay, loop)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (backgroundImg, button, siteMargins, container)
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
                , nthChild "even"
                    [ bpMediumUp
                        [ position absolute
                        , top (px 350)
                        , right zero
                        ]
                    ]
                ]

        casesOuterWrapper =
            styled div
                [ backgroundColor (hex "292A32")
                , marginBottom (px -50)
                , bpMediumUp
                    [ padding2 (px 240) zero
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
                , before
                    [ property "content" "''"
                    , display block
                    , position absolute
                    , top (px -230)
                    , left zero
                    , height (px 230)
                    , width (pct 100)
                    , backgroundImage
                        <| linearGradient
                            (stop (hex "292A32"))
                            (stop (hex content.theme.backgroundColor))
                            []
                    ]
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

        mediaWrapper =
            styled div
                [ overflow hidden
                , height (vh 100)
                , width (vw 100)
                , position relative
                ]

        videoDiv =
            styled div
                [ height (pct 110)
                , width (pct 110)
                , top (pct 50)
                , left (pct 50)
                , transform <| translate2 (pct -50) (pct -50)
                , position absolute
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
            , a [ href content.cover.link ]
                [ UI.Common.button content.theme [] (Just "lees verder")
                ]
            ]
        ]
