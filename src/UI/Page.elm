module UI.Page exposing (container)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class)
import UI.Pages.Home
import UI.Pages.Services
import UI.Pages.Culture
import UI.Pages.Contact
import Dict


containerWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
containerWrapper =
    styled div <|
        [ backgroundColor (hex "001AE0")
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
        activeDepth =
            model.activePage
                |> Maybe.andThen
                    (\activePage ->
                        pageOrder
                            |> List.indexedMap (,)
                            |> List.filterMap
                                (\( index, pageType ) ->
                                    if pageType == activePage then
                                        Just index
                                    else
                                        Nothing
                                )
                            |> List.head
                    )
                |> Maybe.withDefault 0

        pages =
            pageOrder
                |> List.indexedMap (,)
                |> List.map
                    (\( index, pageType ) ->
                        let
                            depth =
                                if index <= activeDepth then
                                    index - activeDepth
                                else
                                    index - activeDepth - List.length pageOrder
                        in
                            pageView model pageType depth
                    )
    in
        containerWrapper [] pages


pageWrapper : Int -> Bool -> MenuState -> List (Attribute msg) -> List (Html msg) -> Html msg
pageWrapper depth locked menuState =
    let
        lockStyle =
            if locked then
                overflowY hidden
            else
                overflowY scroll

        transformStyle =
            case menuState of
                Closed ->
                    [ transforms [] ]

                OpenTop ->
                    [ transforms
                        [ translate2
                            (px 0)
                            (px <| toFloat <| 100 * depth + 200)
                        , scale <| 0.1 * (toFloat depth) + 0.94
                        ]
                    ]

                OpenBottom ->
                    [ transforms
                        [ translate2
                            (px 0)
                            (px <| toFloat <| -100 * depth - 200)
                        , scale <| 0.1 * (toFloat depth) + 0.94
                        ]
                    ]

        extraStyles =
            lockStyle
                :: transformStyle
                ++ [ property "-webkit-overflow-scrolling" "touch"
                   , pseudoElement "-webkit-scrollbar"
                        [ display none
                        ]
                   , property "-ms-overflow-style" "none"
                   , overflowX hidden
                   ]
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

        className =
            Maybe.map2
                (,)
                model.activePage
                (List.head <| String.split "." pageType)
                |> Maybe.map
                    (\( activePage, t ) ->
                        if activePage == pageType then
                            t ++ " page-wrapper active"
                        else
                            t ++ " page-wrapper"
                    )
                |> Maybe.withDefault "page-wrapper"

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
                                Just <| UI.Pages.Culture.view model content

                            Contact content ->
                                Just <| UI.Pages.Contact.view content

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault (text "")
    in
        pageWrapper depth
            locked
            model.menuState
            [ class <| className ]
            [ page
            ]
