module UI.Blocks exposing (..)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (property)
import Json.Encode


streamfield : List Block -> Html msg
streamfield blockData =
    let
        blocks =
            blockData
                |> List.map
                    (\block ->
                        case block of
                            RichTextBlock data ->
                                richText data

                            QuoteBlock data ->
                                quote data
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
