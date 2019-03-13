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
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex content.theme.backgroundColor)
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
                            (stop (hex content.theme.backgroundColor))
                            []
                    ]
                ]

        title =
            styled div
                [ marginBottom (px 20)
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
                , width (pct 100)
                , padding2 zero (px 25)
                , position absolute
                , bottom (px 120)
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
                , bpLargeUp
                    [ padding4 zero (px 120) zero zero
                    , maxWidth (px 620)
                    ]
                ]

        mediaWrapper =
            styled div
                [ overflow hidden
                , height (vh 100)
                , width (vw 100)
                , position absolute
                , bottom zero
                , display none
                , bpMediumUp
                    [ display block
                    ]
                ]

        mobileImageWrapper =
            styled div
                [ display block
                , bpMediumUp
                    [ display none
                    ]
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
                , backgroundSize cover
                , backgroundPosition center
                , top (pct 30)
                , left (pct 50)
                , transform <| translate2 (pct -50) (pct -50)
                , width (px 320)
                , height (px 320)
                , bpMediumUp
                    [ transform <| translate2 (pct -50) (pct -50)
                    , maxHeight (px 700)
                    , maxWidth (px 700)
                    , height (vw 40)
                    , width (vw 40)
                    , top (pct 50)
                    ]
                , bpMedium
                    [ left <| calc (pct 50) minus (px 180)
                    ]
                , bpLargeUp
                    [ left <| calc (pct 50) minus (px 300)
                    ]
                ]

        gifDiv =
            \imageUrl ->
                styled div
                    [ position absolute
                    , backgroundSize cover
                    , backgroundPosition center
                    , backgroundImage (url imageUrl)
                    , top (pct 30)
                    , left (pct 50)
                    , transform <| translate2 (pct -50) (pct -50)
                    , width (px 320)
                    , height (px 320)
                    , bpMediumUp
                        [ transform <| translate2 (pct -50) (pct -50)
                        , maxHeight (px 700)
                        , maxWidth (px 700)
                        , height (vw 40)
                        , width (vw 40)
                        , top (pct 50)
                        ]
                    , bpMedium
                        [ left <| calc (pct 50) minus (px 180)
                        ]
                    , bpLargeUp
                        [ left <| calc (pct 50) minus (px 300)
                        ]
                    ]

        mediaElement =
            content.cover.media
                |> Maybe.andThen
                    (\media ->
                        case media of
                            Wagtail.ImageMedia img ->
                                Just <| imageDiv [ backgroundImg img ] []

                            Wagtail.VideoMedia url ->
                                if (Regex.contains (Maybe.withDefault Regex.never <| Regex.fromString "gif$") url) then
                                    Just <| gifDiv url [] []
                                else
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
        [ mediaElement
        , mobileImageWrapper [] [ imageDiv [ backgroundImg content.cover.mobileImage ] [] ]
        , textWrapper []
            [ title [ class "tags" ] [ text "Uitgelicht" ]
            , richText content.cover.text
            , a [ href content.cover.link ]
                [ UI.Common.button content.theme [] (Just "lees blog")
                ]
            ]
        ]
