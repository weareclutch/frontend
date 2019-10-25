module UI.Components.Navigation exposing (view)

import Css exposing (..)
import Css.Global exposing (global, selector)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, href, id)
import Html.Styled.Events exposing (..)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (burger, cross)
import Style exposing (..)
import Types exposing (..)
import UI.Common exposing (nonAnchorLink)
import UI.State exposing (..)
import Wagtail exposing (..)


type ToggleState
    = Overlay
    | OpenMenu
    | CloseMenu


view : NavigationTree -> NavigationState -> Route -> Maybe ContactInformation -> Html Types.Msg
view navigationTree navigationState route contactInformation =
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

        toggleActions =
            case toggleState of
                OpenMenu ->
                    [ onClick (NavigationMsg <| ChangeNavigation <| Open activeIndex)
                    ]

                CloseMenu ->
                    [ onClick (NavigationMsg <| ChangeNavigation Closed)
                    ]

                _ ->
                    case route of
                        WagtailRoute _ (Wagtail.CasePage _) ->
                            [ nonAnchorLink "/"
                            ]

                        WagtailRoute _ (Wagtail.BlogPostPage content) ->
                            case content.series of
                                Just _ ->
                                    [ nonAnchorLink "../../"
                                    ]

                                Nothing ->
                                    [ nonAnchorLink "../"
                                    ]

                        WagtailRoute _ (Wagtail.BlogCollectionPage _) ->
                            [ nonAnchorLink "../"
                            ]

                        _ ->
                            []

        svgColor =
            (case route of
                WagtailRoute _ page ->
                    Just <| getPageTheme page

                _ ->
                    Nothing
            )
                |> Maybe.map (\theme -> theme.textColor)
                |> Maybe.withDefault "fff"

        outerWrapper =
            styled div
                [ position fixed
                , zIndex (int 100)
                , height (px 0)
                , bpMediumUp
                    [ position absolute
                    , top zero
                    , left zero
                    , width (pct 100)
                    , height auto
                    ]
                ]

        wrapper =
            styled div
                [ position relative
                , width (vw 100)
                , height (vh 100)
                , backgroundColor (hex "001AE0")
                , opacity <|
                    if toggleState == CloseMenu then
                        int 1

                    else
                        int 0
                , if toggleState == CloseMenu then
                    visibility visible

                  else
                    visibility hidden
                , transition "all" 0.2 0 "ease-in-out"
                , overflowY scroll
                , property "-webkit-overflow-scrolling" "touch"
                , overflowX hidden
                , bpMediumUp
                    [ height auto
                    , width auto
                    , backgroundColor transparent
                    , overflow visible
                    ]
                ]

        toggleWrapper =
            styled div
                [ position absolute
                , zIndex (int 110)
                , transition "all" 0.26 0 "ease-in-out"
                , width (px 50)
                , height (px 50)
                , cursor pointer
                , left (px 15)
                , top (px 12)
                , bpMedium
                    [ left (px 40)
                    , top (px 27)
                    ]
                , bpLarge
                    [ left (px 40)
                    , top (px 27)
                    ]
                , bpXLargeUp
                    [ left (px 100)
                    , top (px 68)
                    ]
                ]

        burgerAnimation =
            styled div
                [ width (pct 100)
                , height (pct 100)
                ]

        burgerAnimationStyle =
            global
                [ selector "#burger-animation path"
                    [ fill <|
                        if toggleState == CloseMenu then
                            hex "fff"

                        else
                            hex svgColor
                    ]
                ]

        logoWrapper =
            styled a
                [ position absolute
                , zIndex (int 110)
                , cursor pointer
                , right (px 25)
                , top (px 22)
                , bpMedium
                    [ right (px 40)
                    , top (px 40)
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
            styled div
                [ listStyle none
                , zIndex (int 100)
                , padding4 (px 120) (px 25) (px 20) (px 25)
                , textAlign center
                , width (vw 100)
                , position relative
                , bpMediumUp
                    [ height auto
                    , width (pct 100)
                    , position absolute
                    , paddingBottom zero
                    ]
                , bpMedium
                    [ padding4 (px 38) (px 150) zero (px 150)
                    , width (pct 100)
                    ]
                , bpLarge
                    [ padding4 (px 40) (px 150) zero (px 150)
                    ]
                , bpXLargeUp
                    [ padding4 (px 82) (px 150) zero (px 150)
                    ]
                ]

        menuItemStyle =
            \( active, hoverActive ) ->
                [ width (pct 100)
                , textAlign center
                , display block
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
                , marginBottom (px 24)
                , bpMediumUp
                    [ display inlineBlock
                    , width auto
                    , textAlign left
                    , marginRight (px 30)
                    , marginBottom zero
                    ]
                , lastChild
                    [ marginRight zero
                    , display none
                    , bpMediumUp
                        [ display inlineBlock
                        ]
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
                    , position relative
                    , bottom (px -4)
                    , margin auto
                    , display none
                    , bpMediumUp
                        [ display block
                        ]
                    ]
                ]

        menuItem =
            styled a << menuItemStyle

        menuItemSpan =
            styled span << menuItemStyle

        menuButtonText =
            \visible ->
                styled span
                    [ display none
                    , maxWidth <|
                        if visible then
                            px 200

                        else
                            px 0
                    , marginRight <|
                        if visible then
                            px 30

                        else
                            px 0
                    , opacity <|
                        if visible then
                            int 1

                        else
                            int 0
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
                    , left (px 80)
                    , bpMediumUp
                        [ display inlineBlock
                        ]
                    , bpMedium
                        [ left (px 110)
                        , top (px 38)
                        ]
                    , bpLarge
                        [ left (px 110)
                        , top (px 38)
                        ]
                    , bpXLargeUp
                        [ left (px 170)
                        , top (px 80)
                        ]
                    ]

        contactInfo =
            styled div
                [ textAlign center
                , display block
                , color (hex "fff")
                , bpMediumUp
                    [ display none
                    ]
                ]

        link =
            styled a
                [ color (hex "00FFB0")
                , textDecoration none
                ]

        activeIndex =
            case route of
                WagtailRoute _ page ->
                    navigationTree.items
                        |> List.indexedMap (\x y -> ( x, y ))
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
    outerWrapper []
        [ toggleWrapper toggleActions
            [ burgerAnimation
                [ id "burger-animation" ]
                []
            , burgerAnimationStyle
            ]
        , wrapper []
            [ menuWrapper [] <|
                (navigationTree.items
                    |> List.indexedMap
                        (\index item ->
                            menuItem
                                ( activeIndex == index
                                , case navigationState of
                                    Open i ->
                                        i == index

                                    _ ->
                                        False
                                )
                                [ onMouseOver (NavigationMsg <| ChangeNavigation <| Open index)
                                , class "nav"
                                , href item.path
                                ]
                                [ text item.title ]
                        )
                )
                    ++ [ menuItemSpan
                            ( False
                            , navigationState == OpenContact
                            )
                            [ onClick (NavigationMsg <| ChangeNavigation OpenContact)
                            , onMouseOver (NavigationMsg <| ChangeNavigation <| OpenContact)
                            , class "nav"
                            ]
                            [ text "contact" ]
                       ]
            , contactInformation
                |> Maybe.map
                    (\info ->
                        contactInfo []
                            [ p []
                                [ link [ href <| "mailto:" ++ info.email ] [ text info.email ]
                                , br [] []
                                , link [ href <| "phone:" ++ info.phone ] [ text info.phone ]
                                ]
                            , p []
                                [ span [] [ text "barentszplein 4f" ]
                                , br [] []
                                , span [] [ text "1013NJ" ]
                                , br [] []
                                , span [] [ text "Amsterdam" ]
                                ]
                            ]
                    )
                |> Maybe.withDefault (text "")
            ]
        , menuButtonText
            (toggleState == OpenMenu)
            [ onClick (NavigationMsg <| ChangeNavigation OpenContact)
            , class "nav"
            ]
            [ text "contact" ]
        , menuButtonText
            (toggleState == Overlay)
            ([ class "nav" ] ++ toggleActions)
            [ case route of
                WagtailRoute _ (Wagtail.CasePage _) ->
                    text "cases"

                _ ->
                    text "blog"
            ]
        , logoWrapper [ href "/" ]
            [ logo <|
                case navigationState of
                    Closed ->
                        svgColor

                    _ ->
                        "00ffb0"
            ]
        ]
