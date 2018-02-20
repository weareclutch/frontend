module Icons.Menu exposing (..)

import Html.Styled exposing (Html)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


burger : Html msg
burger =
    svg [ height "18", version "1.1", viewBox "0 0 30 18", width "30" ]
        [ g [ id "menu", transform "translate(3415 -929)" ]
            [ g [ id "Menu" ]
                [ node "use"
                    [ fill "#FFFFFF", transform "translate(-3415 929)", xlinkHref "#burger_fill" ]
                    []
                , text ""
                ]
            ]
        , defs []
            [ Svg.Styled.path [ d "M 0 0L 30 0L 30 4L 0 4L 0 0ZM 0 7L 30 7L 30 11L 0 11L 0 7ZM 30 14L 0 14L 0 18L 30 18L 30 14Z", fillRule "evenodd", id "burger_fill" ]
                []
            , text ""
            ]
        ]


cross : Html msg
cross =
    svg [ height "26", version "1.1", viewBox "0 0 26 26", width "26" ]
        [ g [ id "Canvas", transform "translate(-1187 450)" ]
            [ g [ id "Combined Shape" ]
                [ node "use"
                    [ fill "#ffffff", transform "translate(1187.98 -449.021)", xlinkHref "#cross_fill" ]
                    []
                , text ""
                ]
            ]
        , defs []
            [ Svg.Styled.path [ d "M 12.0209 9.19241L 2.82837 0L 0 2.82843L 9.19238 12.0208L 0 21.2132L 2.82837 24.0416L 12.0208 14.8492L 21.2131 24.0416L 24.0416 21.2132L 14.8492 12.0208L 24.0416 2.82843L 21.2133 0L 12.0209 9.19241Z", fillRule "evenodd", id "cross_fill" ]
                []
            , text ""
            ]
        ]
