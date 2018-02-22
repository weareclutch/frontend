module UI.Blocks exposing (..)

import Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (property)
import UI.Common exposing (backgroundImg, image)
import Css exposing (..)
import Json.Encode


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
                , height (px 1100)
                , width (pct 100)
                , position relative
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
                ]

    in
        wrapper [ ]
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
                , height (px 1100)
                , position relative
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
                ]
    in
        wrapper [ ]
            [ innerWrapper  []
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
                ]
    in
        wrapper [ backgroundImg image ] [ ]


columns : Column -> Column -> Html msg
columns col1 col2 =
    let
        colWrapper =
            styled div
                [ width (pct 50)
                , height (px 1100)
                , nthChild "even"
                    [ position absolute
                    , top zero
                    , right zero
                    ]
                ]
        
    in
        div []
            [ colWrapper [] [ column col1 ]
            , colWrapper [] [ column col2 ]
            ]

column : Column -> Html msg
column col =
    col.image
        |> Maybe.map (imageBlock col.theme)
        |> Maybe.withDefault
            ( col.richText
                |> Maybe.map (contentBlock col.theme)
                |> Maybe.withDefault (text "")
            )
