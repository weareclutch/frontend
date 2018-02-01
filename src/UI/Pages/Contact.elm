module UI.Pages.Contact exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)


view : ServicesContent -> Html msg
view content =
    div [] [ text content.caption ]
