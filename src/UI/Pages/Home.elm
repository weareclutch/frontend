module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Case


view : Model -> HomeContent -> Html Msg
view model content =
    div []
        [ renderHomeContent model content
        ]


renderHomeContent : Model -> HomeContent -> Html Msg
renderHomeContent model content =
    let
        cases =
            content.cases
                |> List.map
                    (\page ->
                        model.activeCase
                            |> Maybe.andThen (\activeCase -> Just (activeCase.id == page.id))
                            |> Maybe.withDefault False
                            |> UI.Case.caseView page model.casePosition
                    )
    in
        div [ class "home" ] cases
