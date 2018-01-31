module UI.Pages.Culture exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)


view : Maybe Page -> Html msg
view page =
    case page of
        Just page ->
            div [] [ text page.title ]

        Nothing ->
            div [] [ text "loading culture" ]
