module UI.PageWrappers exposing (..)

import Wagtail exposing (Page, getPageId)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (..)
import Css exposing (..)
import UI.Pages.Case
import UI.Pages.Home
import UI.Common exposing (addLink)
import Types exposing (Msg(..), Route(..))
import UI.State exposing (NavigationItem, NavigationState(..), NavigationTree)


renderPage : Page -> Html Msg
renderPage page =
    case page of
        Wagtail.HomePage content ->
            UI.Pages.Home.view content

        Wagtail.CasePage content ->
            UI.Pages.Case.view content




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
                                (\(lastIndex, lastItem, lastActive) ->
                                    case navState of
                                        Open openIndex ->
                                                if lastIndex == openIndex then
                                                    (index, item, False) :: acc
                                                else
                                                    (index, item, lastActive) :: acc
                                        _ ->
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
                |> List.map
                    (\(index, item, active) ->
                        navigationPage navState index item active
                    )
        )


createTransform : Int -> Int -> Int -> List Style
createTransform x z r =
    let
        value =
            "perspective(1000px) translate3d(0, "
              ++ (toString x)
              ++ "vh, "
              ++ (toString z)
              ++ "px) "
              ++ "rotateX("
              ++ (toString r)
              ++ "deg)"

    in
        [ property "-webkit-transform" value
        , property "-moz-transform" value
        , property "-ms-transform" value
        , property "transform" value
        ]


navigationPage: NavigationState -> Int -> NavigationItem -> Bool -> Html Msg
navigationPage navState index navItem active =
    let
        zoomStart = -100
        zoomStep = -50
        topStart = 26
        topStep = 6
        rotateStart = -5
        rotateStep = 1

        transformStyle =
            case (active, navState) of
                (True, Closed) ->
                    createTransform
                        0
                        0
                        0

                (True, Open _) ->
                    createTransform
                        (topStart + -index * topStep)
                        (zoomStart + index * zoomStep)
                        0

                (False, Closed) ->
                    createTransform
                        (topStart + 50 + -index * topStep)
                        (zoomStart + 340 + index * (Basics.round <| zoomStep * 0.5))
                        (rotateStart + index * rotateStep)

                (False, Open _) ->
                    createTransform
                        (topStart + 70 + -index * topStep)
                        (zoomStart + index * (Basics.round <| zoomStep * 0.5))
                        (rotateStart + index * rotateStep)

                (_, OpenContact) ->
                    createTransform
                        (topStart + 70 + -index * topStep)
                        (zoomStart + index * (Basics.round <| zoomStep * 0.5))
                        (rotateStart + index * rotateStep)

        wrapper =
            styled div <|
                [ boxShadow4 zero (px 0) (px 50) (rgba 0 0 0 0.2)
                , height (vh 100)
                , width (vw 100)
                , position absolute
                , top zero
                , left zero
                , zIndex (int <| 10 - index)
                , property "transition" "all 0.5s cubic-bezier(0.4, 0.2, 0.2, 1.05)"
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
                        (if (not active && navState == Closed) then
                            [ visibility hidden
                            , opacity zero
                            ]
                        else
                            [ visibility visible
                            , opacity (int 1)
                            ]
                        )
                    ++
                        transformStyle

        attributes =
            if navState /= Closed then
                ( [ onMouseOver (NavigationMsg <| UI.State.ChangeNavigation <| Open index)
                  ]
                    ++
                    (addLink navItem.path)
                )
            else
                []

    in
        wrapper attributes
            [ navItem.page
                |> Maybe.map renderPage
                |> Maybe.withDefault
                    ( styled div
                        [ height (pct 100)
                        , width (pct 100)
                        , backgroundColor (hex navItem.theme.backgroundColor)
                        , padding (px 80)
                        ]
                        []
                        [ text "" ]
                    )
            ]
            



