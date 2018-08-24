module UI.PageWrappers exposing (..)

import Wagtail exposing (Page, getPageId)
import Html.Styled exposing (..)
import Css exposing (..)
import UI.Pages.Case
import UI.Pages.Home
import Types exposing (Msg)
import UI.State exposing (NavigationItem, NavigationState(..), NavigationTree)


renderPage : Page -> Html Msg
renderPage page =
    case page of
        Wagtail.HomePage content ->
            UI.Pages.Home.view content

        Wagtail.CasePage content ->
            UI.Pages.Case.view content



isNavigationPage : NavigationTree -> Page -> Bool
isNavigationPage nav page =
    nav.items
        |> List.any
            (\item ->
                item.id == (getPageId page)
            )



overlayWrapper : Html msg -> Bool -> Html msg
overlayWrapper child active =
    let
        wrapper =
            styled div
                [ zIndex (if active then int 80 else int 0)
                , opacity (if active then int 1 else int 0)
                , position fixed
                , top zero
                , left zero
                , width (vw 100)
                , height (vh 100)
                , property "transition" "all 0.28s ease-in-out"
                , overflowY scroll
                ]

    in
        wrapper [] [ child ]


navigationPages : NavigationState -> List (NavigationItem) -> Html Msg
navigationPages navState navItems =
    div [] <|
        List.indexedMap (navigationPage navState) navItems



navigationPage: NavigationState -> Int -> NavigationItem -> Html Msg
navigationPage navState index navItem =
    let
        transformStyle =
            case navState of
                Closed ->
                    [ transforms [] ]

                Open ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 140 * index + 300)
                        , scale <| 0.1 * (toFloat index) + 0.94
                        ]
                    ]

                OpenContact ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 140 * index + 900)
                        , scale <| 0.1 * (toFloat index) + 0.94
                        ]
                    ]

        extraStyles =
            transformStyle
                ++ [ property "-webkit-overflow-scrolling" "touch"
                   , pseudoElement "-webkit-scrollbar"
                        [ display none
                        ]
                   , property "-ms-overflow-style" "none"
                   , overflowX hidden
                   ]
                ++ (if navState == Closed then
                        [ cursor default
                        , overflowY scroll
                        ]
                    else
                        [ cursor pointer
                        , overflowY hidden
                        ]
                    )

        wrapper =
            styled div <|
                [ boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
                , height (vh 100)
                , width (vw 100)
                , position absolute
                , top zero
                , left zero
                , zIndex (int <| 10 + index)
                , property "transition" "all 0.28s ease-in-out"
                ] 
                    ++ extraStyles
    in
        wrapper []
            [ navItem.page
                |> Maybe.map renderPage
                |> Maybe.withDefault (text "not yet loaded")
            ]
            



