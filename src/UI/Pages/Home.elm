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
                |> List.indexedMap (,)
                |> List.map
                    (\( index, page ) ->
                        model.activeOverlay
                            |> Maybe.andThen (\id -> Just (id == page.id))
                            |> Maybe.withDefault False
                            |> UI.Case.overlay model (List.drop index content.cases)
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
