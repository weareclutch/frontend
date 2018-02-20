module Icons.Menu exposing (..)

import Types exposing (..)
import Html.Styled exposing (Html)
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)


menuToggle : MenuState -> Html msg
menuToggle menuState =
    svg [ height "18", version "1.1", viewBox "0 0 30 18", width "30" ]
        [ g [ id "menu", transform "translate(3415 -929)" ]
            [ g [ id "Menu" ]
                [ node "use"
                    [ fill "#FFFFFF", transform "translate(-3415 929)", xlinkHref "#menuToggle_fill" ]
                    []
                , text ""
                ]
            ]
        , defs []
            [ Svg.Styled.path [ d "M 0 0L 30 0L 30 4L 0 4L 0 0ZM 0 7L 30 7L 30 11L 0 11L 0 7ZM 30 14L 0 14L 0 18L 30 18L 30 14Z", fillRule "evenodd", id "menuToggle_fill" ]
                []
            , text ""
            ]
        ]
