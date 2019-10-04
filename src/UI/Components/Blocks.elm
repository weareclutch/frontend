module UI.Components.Blocks exposing (backgroundBlock, column, columns, contentBlock, imageBlock, quote, richText, streamfield)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, autoplay, loop, property, src)
import Json.Encode as Encode
import Style exposing (..)
import UI.Common exposing (backgroundImg, image)
import Wagtail exposing (Block(..), Column, Image, Quote, Theme)


streamfield : List Block -> Html msg
streamfield blockData =
    let
        blocks =
            blockData
                |> List.map
                    (\block ->
                        case block of
                            QuoteBlock data ->
                                quote data

                            ImageBlock theme image ->
                                imageBlock theme image

                            ContentBlock theme text ->
                                contentBlock theme text

                            BackgroundBlock image ->
                                backgroundBlock image

                            VideoBlock url ->
                                videoBlock url

                            ColumnBlock col1 col2 ->
                                columns col1 col2

                            UnknownBlock blockType ->
                                Debug.log
                                    ("unknown block type: " ++ blockType)
                                    (text "")
                    )
    in
    div [] blocks


richText : String -> Html msg
richText string =
    node "cms-html"
        [ Html.Styled.Attributes.property
            "content"
            (Encode.string string)
        ]
        []


quote : Quote -> Html msg
quote data =
    div [] []



-- div []
--     [ text data.text
--     , text <| Maybe.withDefault "" data.name
--     ]


imageBlock : Theme -> Image -> Html msg
imageBlock theme imageData =
    let
        wrapper =
            styled div
                [ backgroundColor (hex theme.backgroundColor)
                , width (pct 100)
                , height auto
                , position relative
                , overflow hidden
                ]

        innerWrapper =
            styled div
                [ margin auto
                , width auto
                , height auto
                , textAlign center
                ]
    in
    wrapper []
        [ innerWrapper []
            [ image
                [ maxWidth (pct 100)
                , margin2 (px 0) auto
                ]
                imageData
            ]
        ]


backgroundBlock : Image -> Html msg
backgroundBlock imageData =
    let
        wrapper =
            styled div
                [ margin auto
                , width auto
                , height auto
                ]
    in
    wrapper []
        [ image
            [ width (pct 100)
            ]
            imageData
        ]


contentBlock : Theme -> String -> Html msg
contentBlock theme text =
    let
        wrapper =
            styled div
                [ backgroundColor (hex theme.backgroundColor)
                , color (hex theme.textColor)
                , position relative
                , padding2 (px 80) zero
                , bpMediumUp
                    [ padding2 (px 180) zero
                    ]
                ]

        innerWrapper =
            styled div
                [ margin auto
                , maxWidth (px 660)
                , padding2 zero (px 25)
                , fontSize (px 20)
                , lineHeight (px 34)
                , bpMediumUp
                    [ fontSize (px 22)
                    ]
                ]
    in
    wrapper []
        [ innerWrapper []
            [ richText text
            ]
        ]


columns : Column -> Column -> Html msg
columns col1 col2 =
    let
        wrapper =
            styled div
                [ position relative
                , backgroundColor (hex col1.theme.backgroundColor)
                ]

        colWrapper =
            styled div
                [ bpLargeUp
                    [ width (pct 50)
                    , paddingTop (pct 50)
                    , position relative
                    ]
                , nthChild "even"
                    [ bpLargeUp
                        [ position absolute
                        , top zero
                        , right zero
                        ]
                    ]
                ]

        colInnerWrapper =
            styled div
                [ bpLargeUp
                    [ position absolute
                    , top zero
                    , right zero
                    , height (pct 100)
                    , width (pct 100)
                    ]
                ]
    in
    wrapper []
        [ div []
            [ colWrapper []
                [ colInnerWrapper []
                    [ column col1
                    ]
                ]
            , colWrapper []
                [ colInnerWrapper []
                    [ column col2
                    ]
                ]
            ]
        ]


videoBlock : String -> Html msg
videoBlock url =
    let
        wrapper =
            styled div
                [ width (pct 100)
                ]

        videoElement =
            styled video
                [ width (pct 100)
                ]
    in
    wrapper []
        [ videoElement
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


column : Column -> Html msg
column col =
    let
        wrapper =
            styled div
                [ backgroundColor (hex col.theme.backgroundColor)
                , width (pct 100)
                , position relative
                , overflow hidden
                , backgroundSize cover
                , backgroundPosition center
                , bpLargeUp
                    [ height (pct 100)
                    ]
                ]

        videoElement =
            styled video
                [ width (pct 100)
                , height (pct 100)
                , position absolute
                , top zero
                , left zero
                ]

        videoWrapper =
            styled div
                [ position relative
                , margin auto
                , paddingTop (pct 100)
                , width (pct 100)
                , bpLargeUp
                    [ position absolute
                    , height (pct 100)
                    , top zero
                    , left zero
                    , paddingTop zero
                    ]
                ]

        imageWrapper =
            styled div
                [ position relative
                , margin auto
                , paddingTop (pct 100)
                , width (pct 100)
                , backgroundSize2 (pct 100) auto
                , backgroundPosition center
                , backgroundSize cover
                , bpLargeUp
                    [ position absolute
                    , height (pct 100)
                    , top zero
                    , left zero
                    , paddingTop zero
                    ]
                , col.theme.backgroundPosition
                    |> Maybe.map
                        (\pos ->
                            case pos of
                                ( "top", _ ) ->
                                    top

                                ( "bottom", _ ) ->
                                    bottom

                                _ ->
                                    center
                        )
                    |> Maybe.withDefault center
                    |> backgroundPosition
                ]

        backgroundElement background =
            case background of
                Wagtail.CoverBackground image ->
                    imageWrapper [ backgroundImg image ] []

                Wagtail.VideoBackground url ->
                    videoWrapper
                        []
                        [ videoElement
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

        textWrapper =
            styled div
                [ position relative
                , maxWidth (px 820)
                , margin auto
                , width (pct 100)
                , color (hex col.theme.textColor)
                , padding2 (px 80) (px 25)
                , bpMedium
                    [ padding2 (px 180) (px 80)
                    ]
                , bpLargeUp <|
                    [ position absolute
                    , padding2 (px 80) (px 110)
                    , zIndex (int 100)
                    ]
                        ++ (col.theme.backgroundPosition
                                |> Maybe.map
                                    (\pos ->
                                        case pos of
                                            ( "center", _ ) ->
                                                [ top (pct 50)
                                                , left (pct 50)
                                                , transform <| translate2 (pct -50) (pct -50)
                                                ]

                                            ( "bottom", _ ) ->
                                                [ bottom zero
                                                ]

                                            _ ->
                                                []
                                    )
                                |> Maybe.withDefault []
                           )
                ]
    in
    wrapper []
        [ col.background
            |> Maybe.map backgroundElement
            |> Maybe.withDefault
                (col.richText
                    |> Maybe.map (\html -> textWrapper [] [ richText html ])
                    |> Maybe.withDefault (text "")
                )
        ]
