module UI.Pages.Case exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, href, id, style)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (backgroundImg, button)
import UI.Components.Blocks
import UI.Components.CasePoster
import Wagtail


view : Wagtail.CasePageContent -> Html Msg
view content =
    let
        wrapper =
            styled div <|
                [ position relative
                , backgroundColor transparent
                ]

        nextCaseWrapper =
            styled div
                [ minHeight (pct 100)
                , position relative
                , padding (px 40)
                , bpMediumUp
                    [ padding (px 80)
                    ]
                , bpLargeUp
                    [ padding2 (px 160) (px 80)
                    ]
                ]

        nextCase =
            styled div
                [ maxWidth (px 660)
                , margin auto
                , width (pct 100)
                , maxHeight (px 890)
                , height <| calc (vh 100) minus (px 160)
                , position relative
                ]
    in
    wrapper []
        [ header content
        , body content
        , nextCaseWrapper []
            [ nextCase []
                [ UI.Components.CasePoster.view content.info.relatedCase
                ]
            ]
        ]


header : Wagtail.CasePageContent -> Html msg
header content =
    let
        wrapperAttributes =
            content.backgroundImage
                |> Maybe.map
                    (\img ->
                        [ backgroundImg img ]
                    )
                |> Maybe.withDefault []

        newWidth =
            calc (pct 100) plus (px 16)

        headerWrapper =
            styled div <|
                [ width (vw 100)
                , height (vh 150)
                , overflow hidden
                ]

        parallaxWrapper =
            styled div <|
                [ width newWidth
                , height (pct 132)
                , overflowX hidden
                , property "perspective" "300px"
                ]

        groupWrapper =
            styled div <|
                [ width (pct 100)
                , height (pct 100)
                , position relative
                , zIndex (int 30)
                , transitions
                    [ { property = "transform"
                      , duration = 0.5
                      , delay = 0.0
                      , easing = ""
                      }
                    ]
                , transformStyle preserve3d
                ]

        wrapper =
            styled div <|
                [ position absolute
                , top zero
                , right zero
                , bottom zero
                , left zero
                , transforms [ translateZ (px -150), scale 1.5 ]
                , height (pct 100)
                , width (pct 100)
                , overflow hidden
                ]

        imgWrapper =
            styled div <|
                [ backgroundPosition center
                , backgroundSize cover
                , height (pct 100)
                , width (pct 100)
                ]

        titleWrapper =
            styled div
                [ color (hex content.theme.textColor)
                , case String.toLower content.theme.textColor of
                    "fff" ->
                        textShadow4 zero (px 15) (px 30) (rgba 0 0 0 0.4)

                    "ffffff" ->
                        textShadow4 zero (px 15) (px 30) (rgba 0 0 0 0.4)

                    _ ->
                        textShadow none
                , position absolute
                , paddingRight (px 40)
                , height (pct 70)
                , top zero
                , right zero
                , left (px 25)
                , bottom (px 45)
                , zIndex (int 50)
                , displayFlex
                , flexDirection column
                , alignItems flexStart
                , paddingTop (pct 120)
                , transform <| translateZ (px 0)
                , bpMedium
                    [ left (px 40)
                    , height (pct 90)
                    , paddingTop (pct 40)
                    ]
                , bpLarge
                    [ left (px 40)
                    , paddingTop (pct 40)
                    ]
                , bpXLargeUp
                    [ left (px 170)
                    , paddingTop (pct 40)
                    ]
                ]

        caption =
            styled h1
                [ maxWidth (px 1200)
                , paddingRight (px 40)
                , bpMediumUp
                    [ paddingRight zero
                    ]
                , bpMedium
                    [ paddingRight (pct 20)
                    , maxWidth (px 600)
                    ]
                , bpLarge
                    [ maxWidth (px 800)
                    ]
                , bpXLargeUp
                    [ maxWidth (px 1000)
                    ]
                ]

        title =
            styled span
                [ fontSize (px 28)
                , lineHeight (px 36)
                , letterSpacing (px 2)
                , paddingRight (px 40)
                , bpMediumUp
                    [ fontSize (px 26)
                    , paddingRight zero
                    ]
                ]
    in
    headerWrapper
        []
        [ parallaxWrapper [ ]
            [ groupWrapper [ Html.Styled.Attributes.id "case-group-wrapper" ]
                [ titleWrapper [ Html.Styled.Attributes.id "case-text-wrapper" ]
                    [ caption [] [ text content.info.caption ]
                    , title [] [ text content.meta.title ]
                    ]
                , wrapper [] [ imgWrapper wrapperAttributes [] ]
                ]
            ]
        ]


layerImage : Wagtail.Theme -> Wagtail.Image -> Html msg
layerImage theme image =
    let
        size =
            [ width (pct 80)
            , height (pct 50)
            , bpLargeUp
                [ width (px 900)
                , height (px 900)
                ]
            ]

        positionStyles =
            [ transform <| translateY (pct -50)
            , position absolute
            , top (pct 50)
            , right (pct 0)
            , bpLargeUp
                [ right (pct -10)
                ]
            ]

        wrapper =
            styled div <|
                [ backgroundSize contain
                , backgroundPosition center
                ]
                    ++ positionStyles
                    ++ size
    in
    wrapper [ backgroundImg image ] []


body : Wagtail.CasePageContent -> Html msg
body content =
    let
        wrapper =
            styled div <|
                [ position relative
                ]

        blocks =
            content.body
                |> Maybe.andThen
                    (\b ->
                        Just <| UI.Components.Blocks.streamfield b
                    )
                |> Maybe.withDefault (text "")
    in
    wrapper []
        [ intro content
        , blocks
        ]


intro : Wagtail.CasePageContent -> Html msg
intro content =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , backgroundColor (hex "F4F4F4")
                , color (hex "292A32")
                , padding2 (px 80) zero
                , bpLargeUp
                    [ padding2 (px 200) zero
                    ]
                ]

        innerWrapper =
            styled div
                [ width (pct 100)
                , maxWidth (px 1460)
                , position relative
                , margin auto
                ]

        introWrapper =
            styled div
                [ maxWidth (px 940)
                , fontSize (px 20)
                , lineHeight (px 40)
                , padding2 zero (px 25)
                , fontWeight (int 500)
                , bpLargeUp
                    [ width (pct 60)
                    , fontSize (px 28)
                    ]
                ]

        introEl =
            content.intro
                |> Maybe.map UI.Components.Blocks.richText
                |> Maybe.withDefault (text "")

        metaInfo =
            styled div
                [ padding2 zero (px 25)
                , bpLargeUp
                    [ width (pct 40)
                    , position absolute
                    , backgroundColor transparent
                    , right zero
                    , top zero
                    ]
                ]

        metaSection =
            styled div
                [ marginBottom (px 35)
                ]

        description =
            styled div
                [ fontFamilies [ "Qanelas ExtraBold" ]
                , paddingBottom (px 10)
                ]
    in
    wrapper []
        [ innerWrapper []
            [ introWrapper []
                [ introEl
                ]
            , metaInfo []
                -- [ metaSection []
                --     [ description [] [ text "Diensten" ]
                --     ]
                [ metaSection []
                    [ description [] [ text "Periode" ]
                    , div [] [ text "Jan 2018" ]
                    ]
                , if content.info.websiteUrl /= "" then
                    metaSection []
                        [ description [] [ text "Bekijken" ]
                        , a [ href content.info.websiteUrl ] [ text content.info.websiteUrl ]
                        ]

                  else
                    text ""
                ]
            ]
        ]
