module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Common exposing (link)


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ border3 (px 1) solid (hex "bbaaff")
        , position absolute
        , bottom zero
        , right zero
        , zIndex (int 100)
        ]


view : Html Msg
view =
    wrapper []
        [ UI.Common.link "/" [ text "home" ]
        , UI.Common.link "/6/lorem" [ text "casepage" ]
        ]
