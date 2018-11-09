module Icons.Arrow exposing (arrow)

import Html.Styled exposing (Html)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


arrow : String -> Html msg
arrow color =
    svg [ height "17", version "1.1", viewBox "0 0 10 16", width "10" ]
        [ g [ id "Canvas", transform "translate(2042 -8934)" ]
            [ g [ id "arrow" ]
                [ node "use"
                    [ fill ("#" ++ color), transform "matrix(6.12323e-17 1 -1 6.12323e-17 -2032.43 8934)", xlinkHref "#path0_fill" ]
                    []
                , text ""
                ]
            ]
        , defs []
            [ Svg.Styled.path [ d "M 7.95215 0L 0 7.95203L 1.62207 9.57373L 8 3.19592L 14.3779 9.57373L 16 7.95203L 8.04785 0L 8 0.0478516L 7.95215 0Z", fillRule "evenodd", id "path0_fill" ]
                []
            , text ""
            ]
        ]
