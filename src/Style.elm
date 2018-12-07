module Style exposing (bpLarge, bpLargeUp, bpMedium, bpMediumUp, bpSmallOnly, bpXLargeUp, large, medium, small, transition, transitionString, transitions)

import Css exposing (..)
import Css.Media exposing (..)


small : Int
small =
    670


medium : Int
medium =
    1040


large : Int
large =
    1800


bpSmallOnly : List Style -> Style
bpSmallOnly styles =
    withMediaQuery
        [ "only screen and (max-width: " ++ (toString <| small - 1) ++ "px)"
        ]
        styles


bpMedium : List Style -> Style
bpMedium styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ toString small ++ "px) and (max-width: " ++ (toString <| medium - 1) ++ "px)"
        ]
        styles


bpMediumUp : List Style -> Style
bpMediumUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ toString small ++ "px)"
        ]
        styles


bpLarge : List Style -> Style
bpLarge styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ toString medium ++ "px) and (max-width: " ++ (toString <| large - 1) ++ "px)"
        ]
        styles


bpLargeUp : List Style -> Style
bpLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ toString medium ++ "px)"
        ]
        styles


bpXLargeUp : List Style -> Style
bpXLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ toString large ++ "px)"
        ]
        styles


transitionString : String -> Float -> Float -> String -> String
transitionString prop duration delay easing =
    prop ++ " " ++ toString duration ++ "s " ++ toString delay ++ "s " ++ easing


transitions : List ( String, Float, Float, String ) -> Style
transitions transitions =
    transitions
        |> List.map
            (\( prop, duration, delay, easing ) ->
                transitionString prop duration delay easing
            )
        |> String.join ", "
        |> property "transition"


transition : String -> Float -> Float -> String -> Style
transition prop duration delay easing =
    property "transition" <|
        transitionString prop duration delay easing
