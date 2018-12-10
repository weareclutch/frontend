module UI.Components.Navigation exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (..)
import Html.Styled.Attributes exposing (class)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (burger, cross)
import Style exposing (..)
import Types exposing (..)
import UI.Common exposing (addLink)
import UI.State exposing (..)
import Wagtail exposing (..)


type ToggleState
    = Overlay
    | OpenMenu
    | CloseMenu


view : NavigationTree -> NavigationState -> Route -> Html Types.Msg
view navigationTree navigationState route =
    let
        toggleState =
            case ( navigationState, route ) of
                ( Closed, WagtailRoute _ page ) ->
                    if UI.State.isNavigationPage navigationTree page then
                        OpenMenu

                    else
                        Overlay

                _ ->
                    CloseMenu

        svgColor =
            (case route of
                WagtailRoute _ page ->
                    Just <| getPageTheme page

                _ ->
                    Nothing
            )
                |> Maybe.map (\theme -> theme.textColor)
                |> Maybe.withDefault "fff"

        wrapper =
            styled div
                [ position absolute
                , zIndex (int 100)
                , top zero
                , left zero
                , width (pct 100)
                , backgroundColor (hex "0ff")
                ]

        toggleWrapper =
            styled div
                [ position absolute
                , zIndex (int 110)
                , if toggleState == Overlay then visibility hidden else visibility visible
                , opacity <| if toggleState == Overlay then (int 0) else (int 1)
                , transition "all" 0.26 0 "ease-in-out"
                , cursor pointer
                , padding (px 8)
                , left (px 20)
                , top (px 12)
                , bpMedium
                    [ left (px 40)
                    , top (px 25)
                    ]
                , bpLarge
                    [ left (px 40)
                    , top (px 30)
                    ]
                , bpXLargeUp
                    [ left (px 100)
                    , top (px 75)
                    ]
                ]

        burgerWrapper =
            styled div <|
                [ position absolute
                , transition "opacity" 0.2 0 "linear"
                , padding (px 20)
                , top (px -8)
                , left (px -14)
                ]
                    ++ (if toggleState == OpenMenu then
                            [ opacity (int 1)
                            , zIndex (int 10)
                            ]

                        else
                            [ opacity zero
                            , zIndex (int 1)
                            ]
                       )

        crossWrapper =
            styled div <|
                [ transition "opacity" 0.2 0 "linear"
                , position relative
                , padding (px 20)
                , top (px -20)
                , left (px -20)
                ]
                    ++ (if toggleState == CloseMenu then
                            [ opacity (int 1)
                            , zIndex (int 10)
                            ]

                        else
                            [ opacity zero
                            , zIndex (int 1)
                            ]
                       )

        logoWrapper =
            styled div
                [ position absolute
                , zIndex (int 110)
                , cursor pointer
                , right (px 20)
                , top (px 20)
                , bpMedium
                    [ right (px 40)
                    , top (px 25)
                    ]
                , bpLarge
                    [ right (px 40)
                    , top (px 40)
                    ]
                , bpXLargeUp
                    [ right (px 100)
                    , top (px 80)
                    ]
                ]

        menuWrapper =
            styled ul
                [ listStyle none
                , textAlign center
                , opacity <| if toggleState == CloseMenu then (int 1) else (int 0)
                , if toggleState == CloseMenu then visibility visible else visibility hidden
                , zIndex (int 100)
                , position absolute
                , width (pct 100)
                , padding2 (px 20) (px 25)
                , transition "all" 0.2 0 "ease-in-out"
                , bpMedium
                    [ padding2 (px 25) (px 150)
                    ]
                , bpLarge
                    [ padding2 (px 40) (px 150)
                    ]
                , bpXLargeUp
                    [ padding2 (px 82) (px 150)
                    ]
                ]

        menuItem =
            \active hoverActive ->
                styled li
                    [ display inlineBlock
                    , width auto
                    , height (px 30)
                    , top zero
                    , transition "all" 0.26 0 "ease-in-out"
                    , overflow hidden
                    , color <|
                        if active then
                            hex "00FFB0"
                        else
                            hex "fff"
                    , verticalAlign top
                    , cursor pointer
                    , position relative
                    , marginRight (px 30)
                    , lastChild
                        [ marginRight zero
                        ]
                    , after
                        [ property "content" "''"
                        , backgroundColor <|
                            if active then
                                hex "00FFB0"
                            else
                                hex "fff"
                        , transition "width" 0.1 0 "ease-in-out"
                        , opacity <|
                            if hoverActive then
                                int 1
                            else
                                int 0
                        , borderRadius (pct 100)
                        , width (pct 100)
                        , height (px 3)
                        , maxWidth (px 3)
                        , display block
                        , position relative
                        , bottom (px -4)
                        , margin auto
                        ]
                    ]

        contactButton =
            \visible ->
                styled li
                    [ display inlineBlock
                    , maxWidth <| if visible then (px 200) else (px 0)
                    , marginRight <| if visible then (px 30) else (px 0)
                    , opacity <| if visible then (int 1) else (int 0)
                    , width auto
                    , height (px 30)
                    , transition "all" 0.26 0 "ease-in-out"
                    , overflow hidden
                    , zIndex (int 130)
                    , color (hex svgColor)
                    , verticalAlign top
                    , cursor pointer
                    , position absolute
                    , top (px 24)
                    , left (px 70)
                    , bpMedium
                        [ left (px 90)
                        , top (px 37)
                        ]
                    , bpLarge
                        [ left (px 100)
                        , top (px 40)
                        ]
                    , bpXLargeUp
                        [ left (px 160)
                        , top (px 84)
                        ]
                    ]

        activeIndex =
            case route of
                WagtailRoute _ page ->
                    navigationTree.items
                        |> List.indexedMap (,)
                        |> List.foldl
                            (\( index, item ) acc ->
                                if item.id == getPageId page then
                                    index

                                else
                                    acc
                            )
                            0

                _ ->
                    0
    in
    wrapper []
        [ toggleWrapper []
            [ burgerWrapper
                [ onClick (NavigationMsg <| ChangeNavigation <| Open activeIndex)
                ]
                [ burger svgColor
                ]
            , crossWrapper
                [ onClick
                    (NavigationMsg <| ChangeNavigation Closed)
                ]
                [ cross
                    (case navigationState of
                        Closed ->
                            svgColor

                        _ ->
                            "fff"
                    )
                ]
            ]
        , menuWrapper [] <|
            (navigationTree.items
                |> List.indexedMap
                    (\index item ->
                        menuItem
                            (activeIndex == index)
                            (case navigationState of
                                Open i ->
                                    i == index

                                _ ->
                                    False
                            )
                            ([ onMouseOver (NavigationMsg <| ChangeNavigation <| Open index)
                             , class "nav"
                             ]
                                ++ addLink item.path
                            )
                            [ text item.title ]
                    )
            )
                ++ [ menuItem
                        False
                        (navigationState == OpenContact)
                        [ onClick (NavigationMsg <| ChangeNavigation OpenContact)
                        , onMouseOver (NavigationMsg <| ChangeNavigation <| OpenContact)
                        , class "nav"
                        ]
                        [ text "Contact" ]
                   ]
        , contactButton
            (toggleState == OpenMenu)
            [ onClick (NavigationMsg <| ChangeNavigation OpenContact)
            , class "nav"
            ]
            [ text "Contact" ]

        , logoWrapper (addLink "/")
            [ logo <|
                case navigationState of
                    Closed ->
                        svgColor

                    _ ->
                        "00ffb0"
            ]
        ]

