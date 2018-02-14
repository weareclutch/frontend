module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Common exposing (link)


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ position absolute
        , top zero
        , left zero
        , zIndex (int 100)
        ]


view : Html Msg
view =
    wrapper []
        [ UI.Common.link "/" [ text "home" ]
        , text " "
        , UI.Common.link "/services" [ text "services" ]
        , text " "
        , UI.Common.link "/culture" [ text "culture" ]
        , text " "
        , UI.Common.link "/contact" [ text "contact" ]
        ]
