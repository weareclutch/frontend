module UI.Case exposing (view, caseView)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Common exposing (link)
import Dict


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ backgroundColor (hex "bbaaff")
        ]


view : Model -> Html Msg
view model =
    model.activeCase
        |> Maybe.andThen (\id -> Dict.get id model.cases)
        |> Maybe.andThen
            (\page ->
                Just <| caseView page
            )
        |> Maybe.withDefault (div [] [])


caseView : Page -> Html msg
caseView page =
    div [] [ text "case page" ]
