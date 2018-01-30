module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Case
import UI.Common exposing (loremIpsum)


view : Model -> Maybe Page -> Html Msg
view model page =
    page
        |> Maybe.andThen
            (\page ->
                case page.content of
                    HomeContentType content ->
                        Just ( page, content )

                    _ ->
                        Nothing
            )
        |> Maybe.andThen
            (\( page, content ) ->
                Just <|
                    div []
                        [ text page.title
                        , renderHomeContent model content
                        ]
            )
        |> Maybe.withDefault (div [] [])


renderHomeContent : Model -> HomeContent -> Html Msg
renderHomeContent model content =
    let
        cases =
            content.cases
                |> List.map
                    (\page ->
                        model.activeCase
                            |> Maybe.andThen (\activeCase -> Just (activeCase == page.id))
                            |> Maybe.withDefault False
                            |> UI.Case.caseView page model.casePosition
                    )
    in
        div [ class "home" ] cases
