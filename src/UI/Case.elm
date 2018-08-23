module UI.Case exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class, href)
import UI.Common exposing (button, addLink, loremIpsum, backgroundImg)
import UI.Blocks
import Style exposing (..)
import Wagtail


view : Wagtail.CasePageContent -> Html msg
view content =
    let
        wrapper =
            styled div <|
                [ position relative
                ]
    in
        wrapper []
            [ header content
            , body content
            ]


header : Wagtail.CasePageContent -> Html msg
header content =
    let
        wrapperAttributes =
            content.backgroundImage
                |> Maybe.map
                    (\image ->
                        [ backgroundImg image ]
                    )
                |> Maybe.withDefault []

        image =
            content.image
                |> Maybe.map (layerImage content.theme)
                |> Maybe.withDefault (text "")

        outerWrapper =
            styled div <|
                [ backgroundColor (hex "292A32")
                , height (pct 100)
                , width (pct 100)
                ]

        wrapper =
            styled div <|
                [ backgroundColor (hex content.theme.backgroundColor)
                , backgroundPosition center
                , backgroundSize cover
                , position relative
                , height (pct 100)
                , width (pct 100)
                , maxHeight (pct 100)
                , maxWidth (pct 100)
                , top zero
                , left zero
                , overflow hidden
                ]

        titleWrapper =
            styled div
                [ color (hex content.theme.textColor)
                , position absolute
                , paddingRight (px 40)
                , left (px 25)
                , bottom (px 25)
                , bpMedium
                    [ left (px 40)
                    , bottom (px 40)
                    ]
                , bpLarge
                    [ left (px 40)
                    , bottom (pct 50)
                    , transform <| translateY (pct 50)
                    ]
                , bpXLargeUp
                    [ left (px 270)
                    , bottom (pct 50)
                    , transform <| translateY (pct 50)
                    ]
                ]

        title =
            styled h1
                [ maxWidth (px 1200)
                , fontSize (px 40)
                , lineHeight (px 50)
                , letterSpacing (px 2)
                , bpMedium
                    [ fontSize (px 60)
                    , lineHeight (px 70)
                    , letterSpacing (px 3.5)
                    , paddingRight (pct 20)
                    , maxWidth (px 600)
                    ]
                , bpLarge
                    [ fontSize (px 72)
                    , lineHeight (px 80)
                    , letterSpacing (px 6.5)
                    , maxWidth (px 700)
                    ]
                , bpXLargeUp
                    [ fontSize (px 120)
                    , lineHeight (px 130)
                    , letterSpacing (px 8.5)
                    , maxWidth (px 900)
                    ]
                ]

        caption =
            styled span
                [ fontSize (px 26)
                , letterSpacing (px 2)
                ]
    in
        outerWrapper []
            [ wrapper wrapperAttributes
                [ image
                , titleWrapper []
                    [ title [] [ text content.meta.title ]
                    , caption [] [ text content.info.caption ]
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
                    (\body ->
                        Just <| UI.Blocks.streamfield body
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
                , backgroundColor (hex "f8f8f8")
                , color (hex "292A32")
                , padding2 (px 80) zero
                , bpMediumUp
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
                [ maxWidth (px 1345)
                , fontWeight (int 500)
                , padding2 zero (px 25)
                , bpMediumUp
                    [ padding4 zero (px 385) zero (px 40)
                    ]
                ]

        introEl =
            content.intro
                |> Maybe.map (UI.Blocks.richText)
                |> Maybe.withDefault (text "")

        metaInfo =
            styled div
                [ padding2 zero (px 25)
                , bpMediumUp
                    [ position absolute
                    , top zero
                    , right zero
                    , maxWidth (px 360)
                    ]
                ]

        metaSection =
            styled div
                [ marginBottom (px 35)
                , lineHeight (px 34)
                , fontSize (px 22)
                , letterSpacing (px 3.85)
                ]

        description =
            styled div
                [ fontFamilies [ "Qanelas ExtraBold" ]
                ]
    in
        wrapper []
            [ innerWrapper []
                [ introWrapper []
                    [ introEl
                    ]
                , metaInfo []
                    [ metaSection []
                        [ description [] [ text "Diensten" ]
                        ]
                    , metaSection []
                        [ description [] [ text "Periode" ]
                        , div [] [ text "Jan 2018" ]
                        ]
                    , metaSection []
                        [ description [] [ text "Bekijken" ]
                        , a [ href content.info.websiteUrl ] [ text content.info.websiteUrl ]
                        ]
                    ]
                ]
            ]
