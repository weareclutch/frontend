module UI.Page exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Common exposing (link, loremIpsum)
import UI.Case
import Dict


wrapper : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
wrapper locked =
    let
        extraStyles =
            if locked then
                [ overflow hidden
                ]
            else
                [ overflow auto
                ]
    in
        styled div <|
            [ backgroundColor (hex "fff")
            , height (vh 100)
            , width (vw 100)
            , position absolute
            , top zero
            , left zero
            , padding (px 80)
            ]
                ++ extraStyles


view : Model -> Html Msg
view model =
    case Dict.get (toString model.activePage) model.pages of
        Just page ->
            case page.content of
                HomeContentType data ->
                    homePage data model.activeCase model.casePosition

                _ ->
                    wrapper False [] [ text "uknown pagetype" ]

        Nothing ->
            wrapper False [] [ text "not loaded" ]


homePage : HomeContent -> Maybe Int -> ( Float, Float ) -> Html Msg
homePage content activeCase position =
    let
        cases =
            content.cases
                |> List.map
                    (\page ->
                        activeCase
                            |> Maybe.andThen (\activeCase -> Just (activeCase == page.id))
                            |> Maybe.withDefault False
                            |> UI.Case.caseView page position
                    )

        locked =
            activeCase
                |> Maybe.map (\activeCase -> True)
                |> Maybe.withDefault False
    in
        wrapper locked
            [ class "home" ]
            [ loremIpsum
            , loremIpsum
            , div [] cases
            , loremIpsum
            , loremIpsum
            ]
