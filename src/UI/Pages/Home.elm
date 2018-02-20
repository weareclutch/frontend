module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class)
import UI.Case
import UI.Blocks exposing (richText)
import Dict


view : Model -> HomeContent -> Html Msg
view model content =
    let
        pageScroll =
            model.pageScrollPositions
                |> Dict.get "home.HomePage"
                |> Maybe.withDefault 0

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
            , introCover pageScroll content
            ]


pageWrapper : List (Html Msg) -> Html Msg
pageWrapper children =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , position relative
                , zIndex (int 10)
                , backgroundColor (hex "292A32")
                , padding (px 140)
                ]

        innerWrapper =
            styled div
                [ maxWidth (px 900)
                , margin auto
                ]
    in
        wrapper []
            [ innerWrapper [] children
            ]


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
                , position absolute
                , borderRadius (pct 50)
                , backgroundColor (hex "711826")
                ]
    in
        wrapper [] []


introCover : Float -> HomeContent -> Html msg
introCover offset content =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , position relative
                , zIndex (int 5)
                ]

        text =
            styled div
                [ color (hex content.theme.textColor)
                , maxWidth (px 500)
                , margin auto
                , transform (translateY (pct -50))
                , top (pct 50)
                , left (pct 50)
                , position absolute
                ]
    in
        wrapper []
            [ logo
            , text []
                [ richText content.cover.text
                ]
            ]
