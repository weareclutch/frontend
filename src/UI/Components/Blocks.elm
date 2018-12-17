module UI.Components.Blocks exposing (backgroundBlock, column, columns, contentBlock, imageBlock, quote, richText, streamfield)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (attribute, autoplay, loop, property, src)
import Json.Encode
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
    div
        [ Html.Styled.Attributes.property "innerHTML" (Json.Encode.string string)
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
                , padding2 (px 40) zero
                ]
    in
    wrapper []
        [ innerWrapper []
            [ image [] imageData
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
                    , height (vh 100)
                    ]
                , nthChild "even"
                    [ bpLargeUp
                        [ position absolute
                        , top zero
                        , right zero
                        ]
                    ]
                ]
    in
    wrapper []
        [ div []
            [ colWrapper [] [ column col1 ]
            , colWrapper [] [ column col2 ]
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
                    [ height (vh 100)
                    ]
                ]

        videoWrapper =
            styled video
                [ width (pct 100)
                , height (pct 100)
                ]

        imageWrapper =
            styled div
                [ position relative
                , margin auto
                , paddingTop (pct 100)
                , width (pct 100)
                , backgroundSize2 (pct 100) auto
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
                Wagtail.ImageBackground image ->
                    Just <| imageWrapper [ backgroundImg image.image ] []

                Wagtail.VideoBackground url ->
                    Just <|
                        imageWrapper
                            []
                            [ videoWrapper
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

        attributes background =
            case background of
                Wagtail.CoverBackground url ->
                    Just [ backgroundImg url ]

                Wagtail.ImageBackground image ->
                    case image.backgroundImage of
                        Just url ->
                            Just [ backgroundImg url ]

                        _ ->
                            Just []

                _ ->
                    Just []

        textWrapper =
            styled div
                [ position relative
                , maxWidth (px 820)
                , margin auto
                , padding2 (px 40) (px 25)
                , width (pct 100)
                , color (hex col.theme.textColor)
                , bpLargeUp <|
                    [ position absolute
                    , left zero
                    , padding2 (px 80) (px 40)
                    , zIndex (int 100)
                    ]
                        ++ (col.theme.backgroundPosition
                                |> Maybe.map
                                    (\pos ->
                                        case pos of
                                            ( "center", _ ) ->
                                                [ top (pct 50)
                                                , transform <| translateY (pct -50)
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
    wrapper
        (col.background
            |> Maybe.andThen attributes
            |> Maybe.withDefault []
        )
        [ col.background
            |> Maybe.andThen backgroundElement
            |> Maybe.withDefault (text "")
        , col.richText
            |> Maybe.map (\html -> textWrapper [] [ richText html ])
            |> Maybe.withDefault (text "")
        ]
