module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Case
import UI.Common exposing (loremIpsum)


view : Model -> HomeContent -> Html Msg
view model content =
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
        div [ class "home" ] <|
            [ loremIpsum
            , loremIpsum
            , loremIpsum
            , loremIpsum
            , loremIpsum
            , loremIpsum
            ]
                ++ cases
                ++ [ loremIpsum
                   , loremIpsum
                   , loremIpsum
                   , loremIpsum
                   , loremIpsum
                   , loremIpsum
                   ]
