module Icons.Arrow exposing (arrow)

import Html.Styled exposing (Html)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


arrow : String -> Html msg
arrow color =
    svg [ width "11", height "17" ] [ Svg.Styled.path [ d "M.36 2.12L2.5 0l8.48 8.49-8.48 8.48-2.13-2.12 6.37-6.36L.36 2.12z", fill <| "#" ++ color, fillRule "nonzero" ] [] ]

