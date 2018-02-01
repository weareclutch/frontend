module UI.Page exposing (container)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Pages.Home
import UI.Pages.Services
import UI.Pages.Culture
import UI.Pages.Contact
import Dict


containerWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
containerWrapper =
    styled div <|
        [ backgroundColor (hex "f5f5f5")
        , height (vh 100)
        , width (vw 100)
        , position absolute
        , top zero
        , left zero
        ]


pageOrder : List String
pageOrder =
    [ "contact.ContactPage"
    , "culture.CulturePage"
    , "service.ServicesPage"
    , "home.HomePage"
    ]


container : Model -> Html Msg
container model =
    let
        pages =
            pageOrder
                |> List.indexedMap (,)
                |> List.map
                    (\( index, pageType ) ->
                        pageView model pageType (index - List.length pageOrder)
                    )
    in
        containerWrapper [] pages


pageWrapper : Int -> Bool -> Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
pageWrapper depth locked menuActive =
    let
        lockStyle =
            if locked then
                overflow hidden
            else
                overflow auto

        transformStyle =
            if menuActive then
                [ transforms
                    [ translate2
                        (px 0)
                        (px <| toFloat <| 100 * depth + 200)
                    , scale <| 0.1 * (toFloat depth) + 0.94
                    ]
                ]
            else
                [ transforms [] ]

        extraStyles =
            lockStyle :: transformStyle ++ []
    in
        styled div <|
            [ backgroundColor (hex "fff")
            , boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
            , height (vh 100)
            , width (vw 100)
            , position absolute
            , top zero
            , left zero
            , zIndex (int <| 10 + depth)
            , property "transition" "all 0.28s ease-in-out"
            ]
                ++ extraStyles


pageView : Model -> String -> Int -> Html Msg
pageView model pageType depth =
    let
        locked =
            model.activeCase
                |> Maybe.map (\activeCase -> True)
                |> Maybe.withDefault False

        page =
            model.pages
                |> Dict.get pageType
                |> Maybe.andThen
                    (\page ->
                        case page of
                            Home content ->
                                Just <| UI.Pages.Home.view model content

                            Services content ->
                                Just <| UI.Pages.Services.view content

                            Culture content ->
                                Just <| UI.Pages.Culture.view content

                            Contact content ->
                                Just <| UI.Pages.Contact.view content

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault (text "")
    in
        pageWrapper depth
            locked
            model.menuActive
            []
            [ page
            ]
