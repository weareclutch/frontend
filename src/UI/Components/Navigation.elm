module UI.Components.Navigation exposing (view)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Events exposing (..)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (burger, cross)
import UI.Common exposing (addLink)
import Style exposing (..)
import UI.State exposing (..)
import Types exposing (..)
import Wagtail exposing (..)


type ToggleState
    = CloseOverlay
    | OpenMenu
    | CloseMenu


view : NavigationTree -> NavigationState -> Route -> Html Types.Msg
view navigationTree navigationState route =
    let
        toggleState =
            case (navigationState, route) of
                (Closed, WagtailRoute _ page) ->
                    if (UI.State.isNavigationPage navigationTree page) then
                        OpenMenu
                    else
                        CloseOverlay

                _ -> CloseMenu

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
                , cursor pointer
                , padding (px 8)
                , right (px 20)
                , top (px 12)
                , bpMedium
                    [ right (px 40)
                    , top (px 25)
                    ]
                , bpLarge
                    [ right (px 40)
                    , top (px 30)
                    ]
                , bpXLargeUp
                    [ right (px 100)
                    , top (px 75)
                    ]
                ]

        burgerWrapper =
            styled div <|
                [ position absolute
                , transition "opacity" 0.2 0 "linear"
                , padding (px 20)
                , top (px -8)
                , right (px -14)
                ]
                  ++
                    if toggleState == OpenMenu then
                        [ opacity (int 1)
                        , zIndex (int 10)
                        ]
                    else
                        [ opacity zero
                        , zIndex (int 1)
                        ]

        crossWrapper =
            styled div <|
                [ transition "opacity" 0.2 0 "linear"
                , position relative
                , padding (px 20)
                , top (px -20)
                , right (px -20)
                ]
                  ++
                    if toggleState /= OpenMenu then
                        [ opacity (int 1)
                        , zIndex (int 10)
                        ]
                    else
                        [ opacity zero
                        , zIndex (int 1)
                        ]

        logoWrapper =
            styled div
                [ position absolute
                , zIndex (int 110)
                , cursor pointer
                , left (px 20)
                , top (px 20)
                , bpMedium
                    [ left (px 40)
                    , top (px 25)
                    ]
                , bpLarge
                    [ left (px 40)
                    , top (px 40)
                    ]
                , bpXLargeUp
                    [ left (px 100)
                    , top (px 80)
                    ]
                ]

        menuWrapper =
            (\navigationState ->
                let
                    extraStyle =
                        case navigationState of
                            Closed ->
                                [ opacity zero
                                , visibility hidden
                                ]

                            _ ->
                                [ opacity (int 1)
                                , visibility visible
                                ]
                in
                    styled ul <|
                        [ listStyle none
                        , textAlign center
                        , position absolute
                        , width (pct 100)
                        , margin2 (px 20) (px 25)
                        , transition "all" 0.2 0 "ease-in-out"
                        , bpMedium
                            [ margin2 (px 25) (px 40)
                            ]
                        , bpLarge
                            [ margin2 (px 40) (px 40)
                            ]
                        , bpXLargeUp
                            [ margin2 (px 82) (px 40)
                            ]
                        ]
                            ++ extraStyle
            )

        menuItem =
            (\active hoverActive ->
                styled li
                    [ display inlineBlock
                    , color <| if active then hex "00FFB0" else hex "fff"
                    , margin2 zero (px 30)
                    , fontFamilies [ "Qanelas ExtraBold" ]
                    , fontWeight (int 400)
                    , letterSpacing (px 3.5)
                    , fontSize (px 20)
                    , cursor pointer
                    , position relative
                    , after
                        [ property "content" "''"
                        , backgroundColor <| if active then hex "00FFB0" else hex "fff"
                        , transition "width" 0.1 0 "ease-in-out"
                        , opacity <| if hoverActive then (int 1) else (int 0)
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
            )


        activeIndex =
            case route of
                WagtailRoute _ page ->
                    navigationTree.items
                        |> List.indexedMap (,)
                        |> List.foldl
                            (\(index, item) acc ->
                                if item.id == getPageId(page) then
                                    index
                                else
                                    acc
                            )
                            0
                _ ->
                    0

        svgColor =
            (case route of
                WagtailRoute _ page -> Just <| getPageTheme page
                _ -> Nothing
            )
            |> Maybe.map (\theme -> theme.textColor)
            |> Maybe.withDefault "fff"


    in
        wrapper []
            [ toggleWrapper []
                [ burgerWrapper
                    [ onClick (NavigationMsg <| ChangeNavigation <| Open activeIndex)
                    ]
                    [ burger svgColor
                    ]
                , crossWrapper
                    (case toggleState of
                        CloseOverlay ->
                            -- Perhaps we should be looking here at what page the user came from.
                            addLink "/"
                        _ ->
                            [ onClick
                                (NavigationMsg <| ChangeNavigation Closed)
                            ]
                    )
                    [ cross
                        (case navigationState of
                            Closed -> svgColor
                            _ -> "fff"
                        )
                    ]
                ]
            , menuWrapper navigationState [] <|
                (navigationTree.items
                    |> List.indexedMap
                        (\index item ->
                            menuItem
                                (activeIndex == index)
                                (
                                    case navigationState of
                                        Open i -> i == index
                                        _ -> False
                                )
                                ( [ onMouseOver (NavigationMsg <| ChangeNavigation <| Open index)
                                  ]
                                    ++
                                    (addLink item.path)
                                )
                                [ text item.title ]
                        )
                  )
                    ++
                    [ menuItem
                      False
                      (navigationState == OpenContact)
                      (
                          [ onMouseOver (NavigationMsg <| ChangeNavigation <| OpenContact)
                          , onClick (NavigationMsg <| ChangeNavigation OpenContact)
                          ]
                      )
                      [ text "Contact" ]
                    ]
            , logoWrapper (addLink "/")
                [ logo <|
                    (case navigationState of
                        Closed -> svgColor
                        _ -> "00ffb0"
                    )
                ]
            ]
