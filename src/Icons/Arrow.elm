module Icons.Arrow exposing (arrow)

import Html.Styled exposing (Html)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


arrow : String -> Html msg
arrow color =
    svg [ width "11", height "17" ] [ Svg.Styled.path [ d "M.4 2.1L2.5 0 11 8.5 2.5 17 .4 14.8l6.3-6.3L.4 2z", fill <| "#" ++ color, fillRule "nonzero" ] [] ]

