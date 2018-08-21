module UI.Blocks exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (property)
import UI.Common exposing (backgroundImg, image)
import Css exposing (..)
import Json.Encode
import Style exposing (..)
import Types exposing (..)


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
        [ (Html.Styled.Attributes.property "innerHTML" (Json.Encode.string string))
        ]
        []


quote : Quote -> Html msg
quote data =
    div []
        [ text data.text
        , text <| Maybe.withDefault "" data.name
        ]


imageBlock : Theme -> Image -> Html msg
imageBlock theme imageData =
    let
        wrapper =
            styled div
                [ backgroundColor (hex theme.backgroundColor)
                , width (pct 100)
                , height (vh 80)
                , position relative
                , bpLargeUp
                    [ height (px 1100)
                    ]
                ]

        innerWrapper =
            styled div
                [ position absolute
                , top (pct 50)
                , left (pct 50)
                , transform <|
                    translate2
                        (pct -50)
                        (pct -50)
                , maxWidth (px 660)
                , margin auto
                , padding2 zero (px 25)
                ]
    in
        wrapper []
            [ innerWrapper []
                [ image imageData
                ]
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
                ]
    in
        wrapper []
            [ innerWrapper []
                [ richText text
                ]
            ]


contentTallBlock : Theme -> String -> Html msg
contentTallBlock theme text =
    let
        wrapper =
            styled div
                [ backgroundColor (hex theme.backgroundColor)
                , color (hex theme.textColor)
                , position relative
                , padding2 (px 80) zero
                , bpLargeUp
                    [ height (px 1100)
                    , padding zero
                    ]
                ]

        innerWrapper =
            styled div
                [ position relative
                , maxWidth (px 660)
                , margin auto
                , padding2 zero (px 25)
                , bpLargeUp
                    [ position absolute
                    , padding2 zero (px 25)
                    , top (pct 50)
                    , left (pct 50)
                    , transform <|
                        translate2
                            (pct -50)
                            (pct -50)
                    ]
                ]
    in
        wrapper []
            [ innerWrapper []
                [ richText text
                ]
            ]


backgroundBlock : Image -> Html msg
backgroundBlock image =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 80)
                , backgroundSize cover
                , backgroundPosition center
                ]
    in
        wrapper [ backgroundImg image ] []


columns : Column -> Column -> Html msg
columns col1 col2 =
    let
        wrapper =
            styled div
                [ position relative
                ]

        colWrapper =
            styled div
                [ bpLargeUp
                    [ width (pct 50)
                    , height (px 1100)
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
            [ colWrapper [] [ column col1 ]
            , colWrapper [] [ column col2 ]
            ]


column : Column -> Html msg
column col =
    col.image
        |> Maybe.map (imageBlock col.theme)
        |> Maybe.withDefault
            (col.richText
                |> Maybe.map (contentTallBlock col.theme)
                |> Maybe.withDefault (text "")
            )
