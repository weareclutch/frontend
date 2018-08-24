module UI.PageWrappers exposing (..)

import Wagtail exposing (Page, getPageId)
import Html.Styled exposing (..)
import Css exposing (..)
import UI.Pages.Case
import UI.Pages.Home
import Types exposing (Msg, Route(..))
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




navigationPages : NavigationState -> List (NavigationItem) -> Route -> Html Msg
navigationPages navState navItems route =
    div []
        (
            navItems
                |> List.indexedMap (,)
                |> List.foldr
                    (\(index, item) acc ->
                        List.head acc
                            |> Maybe.map
                                (\(_, lastItem, lastActive) ->
                                    case route of
                                        WagtailRoute page ->
                                                if lastItem.id == getPageId(page) then
                                                    (index, item, False) :: acc
                                                else
                                                    (index, item, lastActive) :: acc
                                        _ ->
                                            (index, item, lastActive) :: acc

                                )
                            |> Maybe.withDefault
                                ((index, item, True) :: acc)
                    )
                    []
                -- |> List.map (\(x, y, z) -> Debug.log ((toString x) ++ " " ++ (toString z)) (x, y, z))
                |> List.map
                    (\(index, item, active) ->
                        navigationPage navState index item active
                    )
        )



navigationPage: NavigationState -> Int -> NavigationItem -> Bool -> Html Msg
navigationPage navState index navItem active =
    let
        transformStyle =
            case (active, navState) of
                (False, Closed) ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 80 * -index + 1100)
                        ]
                    , opacity zero
                    , visibility hidden
                    ]

                (True, Closed) ->
                    [ transforms []
                    , opacity (int 1)
                    ]

                (True, Open) ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 80 * -index + 300)
                        , scale <| 0.06 * (toFloat -index) + 0.94
                        ]
                    , opacity (int 1)
                    ]

                (False, Open) ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 80 * -index + 1100)
                        , scale <| 0.06 * (toFloat -index) + 0.94
                        ]
                    , opacity (int 1)
                    ]

                (_, OpenContact) ->
                    [ transforms
                        [ translate2
                            zero
                            (px <| toFloat <| 80 * -index + 1100)
                        , scale <| 0.06 * (toFloat -index) + 0.94
                        ]
                    , opacity (int 1)
                    ]

        wrapper =
            styled div <|
                [ boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
                , height (vh 100)
                , width (vw 100)
                , position absolute
                , top zero
                , left zero
                , zIndex (int <| 10 - index)
                , property "transition" "all 0.28s ease-in-out"
                , property "-webkit-overflow-scrolling" "touch"
                , pseudoElement "-webkit-scrollbar"
                    [ display none
                    ]
                , property "-ms-overflow-style" "none"
                , overflowX hidden
                ] 
                  ++
                    (if navState == Closed then
                        [ cursor default
                        , overflowY scroll
                        ]
                    else
                        [ cursor pointer
                        , overflowY hidden
                        ]
                    )
                    ++
                    transformStyle
    in
        wrapper []
            [ navItem.page
                |> Maybe.map renderPage
                |> Maybe.withDefault
                    ( styled div
                        [ height (pct 100)
                        , width (pct 100)
                        , backgroundColor (hex "fff")
                        ]
                        []
                        [ text "" ]
                    )
            ]
            



