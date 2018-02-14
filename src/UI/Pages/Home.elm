module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
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
                |> List.reverse
    in
        div [ class "home" ] <|
            [ pageWrapper cases
            , introCover
            ]

pageWrapper : List (Html Msg) -> Html Msg
pageWrapper children =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , position relative
                , zIndex (int 10)
                , backgroundColor (hex "fff")
                ]
    in
        wrapper [] children

logo : Html msg
logo =
    let
        wrapper =
            styled div
                [ width (px 200)
                , height (px 200)
                , top (pct 50)
                , marginTop (px -100)
                , left (pct 50)
                , marginLeft (px -100)
                , position fixed
                , borderRadius (pct 50)
                , backgroundColor (hex "f3b100")
                ]
    in
        wrapper [] []

introCover : Html msg
introCover =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex "701923")
                , backgroundAttachment fixed
                , position relative
                , zIndex (int 5)
                ]

    in
        wrapper []
            [ logo
            ]


