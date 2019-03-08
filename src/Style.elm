module Style exposing (..)

import Css exposing (..)
import Css.Media exposing (..)


small : Int
small =
    780


medium : Int
medium =
    1180


large : Int
large =
    1440


xLarge : Int
xLarge =
    1800


bpSmallOnly : List Style -> Style
bpSmallOnly styles =
    withMediaQuery
        [ "only screen and (max-width: " ++ (String.fromInt <| small - 1) ++ "px)"
        ]
        styles


bpMedium : List Style -> Style
bpMedium styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt small ++ "px) and (max-width: " ++ (String.fromInt <| medium - 1) ++ "px)"
        ]
        styles


bpMediumUp : List Style -> Style
bpMediumUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt small ++ "px)"
        ]
        styles


bpLarge : List Style -> Style
bpLarge styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt medium ++ "px) and (max-width: " ++ (String.fromInt <| large - 1) ++ "px)"
        ]
        styles


bpLargeUp : List Style -> Style
bpLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt medium ++ "px)"
        ]
        styles


bpXLarge : List Style -> Style
bpXLarge styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt large ++ "px) and (max-width: " ++ (String.fromInt <| xLarge - 1) ++ "px)"
        ]
        styles


bpXLargeUp : List Style -> Style
bpXLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt large ++ "px)"
        ]
        styles


bpXXLargeUp : List Style -> Style
bpXXLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ String.fromInt xLarge ++ "px)"
        ]
        styles


transitionString : String -> Float -> Float -> String -> String
transitionString prop duration delay easing =
    prop ++ " " ++ String.fromFloat duration ++ "s " ++ String.fromFloat delay ++ "s " ++ easing


transitions : List { property : String, duration : Float, delay : Float, easing: String } -> Style
transitions list =
    list
        |> List.map
            (\{ property, duration, delay, easing } ->
                transitionString property duration delay easing
            )
        |> String.join ", "
        |> property "transition"


transition : String -> Float -> Float -> String -> Style
transition prop duration delay easing =
    property "transition" <|
        transitionString prop duration delay easing
