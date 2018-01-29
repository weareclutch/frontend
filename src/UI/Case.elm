module UI.Case exposing (view, caseView)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Common exposing (addLink, loremIpsum)
import Dict


outerWrapper : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
outerWrapper active =
    let
        extraStyle =
            if active then
                []
            else
                [ zIndex (int 0)
                ]
    in
        styled div <|
            [ zIndex (int 80)
            , position absolute
            , top zero
            , left zero
            , width (vw 100)
            , height (vh 100)
            ]
                ++ extraStyle


wrapper : Bool -> ( Float, Float ) -> List (Attribute msg) -> List (Html msg) -> Html msg
wrapper active ( x, y ) =
    let
        extraStyle =
            if active then
                [ overflowY scroll
                , width (vw 100)
                , height (vh 100)
                , transforms
                    [ translate2
                        (px -x)
                        (px -y)
                    , translateZ zero
                    ]
                , property "transition" "all 0.28s ease-in"
                ]
            else
                [ overflow hidden
                , width (px 300)
                , height (px 300)
                ]
    in
        styled div <|
            [ backgroundColor (hex "bbfaaa")
            , property "transition" "all 0.28s ease-out"
            , position relative
            , width (px 300)
            , height (px 300)
            , property "will-change" "width, height, transform"
            , transform <| translateZ zero
            ]
                ++ extraStyle


view : Model -> Html Msg
view model =
    model.activeCase
        |> Maybe.andThen (\id -> Dict.get id model.cases)
        |> Maybe.andThen
            (\page ->
                case Dict.get (toString model.activePage) model.pages of
                    Just _ ->
                        Nothing

                    Nothing ->
                        Just <|
                            outerWrapper True
                                []
                                [ caseView page ( 0, 0 ) True
                                ]
            )
        |> Maybe.withDefault (outerWrapper False [] [])


caseView : Page -> ( Float, Float ) -> Bool -> Html Msg
caseView page position active =
    let
        className =
            class <| "case-" ++ (toString page.id)

        attributes =
            if active then
                [ className
                ]
            else
                [ className
                ]
                    ++ (addLink <| "/" ++ (toString page.id) ++ "/lorem")
    in
        wrapper active
            position
            attributes
            []
