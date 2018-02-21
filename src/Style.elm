module Style exposing (..)

import Css.Media exposing (..)
import Css exposing (..)


small : Int
small =
    770


medium : Int
medium =
    1240


large : Int
large =
    1580


bpSmallOnly : List Style -> Style
bpSmallOnly styles =
    withMediaQuery
        [ "only screen and (max-width: " ++ (toString <| small - 1) ++ "px)"
        ]
        styles


bpMedium : List Style -> Style
bpMedium styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ (toString small) ++ "px) and (max-width: " ++ (toString <| medium - 1) ++ "px)"
        ]
        styles


bpMediumUp : List Style -> Style
bpMediumUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ (toString small) ++ "px)"
        ]
        styles


bpLarge : List Style -> Style
bpLarge styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ (toString medium) ++ "px) and (max-width: " ++ (toString <| large - 1) ++ "px)"
        ]
        styles


bpLargeUp : List Style -> Style
bpLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ (toString medium) ++ "px)"
        ]
        styles


bpXLargeUp : List Style -> Style
bpXLargeUp styles =
    withMediaQuery
        [ "only screen and (min-width: " ++ (toString large) ++ "px)"
        ]
        styles
