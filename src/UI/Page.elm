module UI.Page exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Common exposing (link)
import UI.Case
import Dict


wrapper : List (Attribute msg) -> List (Html msg) -> Html msg
wrapper =
    styled div
        [ backgroundColor (hex "aabbff")
        ]


view : Model -> Html Msg
view model =
    case Dict.get (toString model.activePage) model.pages of
        Just page ->
            case page.content of
                HomeContentType data ->
                    homePage data model.activeCase

                _ ->
                    wrapper [] [ text "uknown pagetype" ]

        Nothing ->
            wrapper [] [ text "not loaded" ]


homePage : HomeContent -> Maybe Int -> Html Msg
homePage content activeCase =
    let
        cases =
            content.cases
                |> List.map
                    (\page ->
                        activeCase
                            |> Maybe.andThen (\activeCase -> Just (activeCase == page.id))
                            |> Maybe.withDefault False
                            |> UI.Case.caseView page
                    )
    in
        wrapper []
            [ text "homepage"
            , div [] cases
            ]
