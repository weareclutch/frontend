module UI.PageWrappers exposing (createTransform, desktopView, mobileView, navigationPage, navigationPages, overlayPart, overlayWrapper, overlays, renderPage)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, href, id)
import Html.Styled.Events exposing (..)
import Style exposing (..)
import Types exposing (Msg(..), Route(..))
import UI.Common exposing (nonAnchorLink)
import UI.Pages.AboutUs
import UI.Pages.Blog
import UI.Pages.Case
import UI.Pages.Home
import UI.Pages.Services
import UI.State exposing (NavigationItem, NavigationState(..), NavigationTree, OverlayPart, OverlayState)
import Wagtail exposing (Page, getPageId)


renderPage : Bool -> Int -> Page -> Html Msg
renderPage isMobile logoIndex page =
    case page of
        Wagtail.HomePage content ->
            UI.Pages.Home.view content logoIndex

        Wagtail.CasePage content ->
            UI.Pages.Case.view content

        Wagtail.BlogOverviewPage content ->
            UI.Pages.Blog.overview content

        Wagtail.BlogPostPage content ->
            UI.Pages.Blog.post content

        Wagtail.BlogCollectionPage content ->
            UI.Pages.Blog.collection content

        Wagtail.ServicesPage content ->
            UI.Pages.Services.view isMobile content

        Wagtail.AboutUsPage content ->
            UI.Pages.AboutUs.view isMobile content


mobileView : Html a -> Html a
mobileView child =
    let
        wrapper =
            styled div
                [ bpMediumUp
                    [ display none
                    ]
                ]
    in
    wrapper [ class "mobile" ] [ child ]


desktopView : Html a -> Html a
desktopView child =
    let
        wrapper =
            styled div
                [ display none
                , bpMediumUp
                    [ display block
                    ]
                ]
    in
    wrapper [] [ child ]


overlays : OverlayState -> Int -> Html Msg
overlays state logoIndex =
    let
        wrapper =
            styled div
                [ position fixed
                , top
                    (if state.active then
                        vh 0

                     else
                        vh 100
                    )
                , zIndex (int 78)
                , left zero
                , width (vw 100)
                , height (vh 100)
                , property "transition" <|
                    if state.active then
                        "top 0s ease-in-out"

                    else
                        "top 0.5s ease-in-out"
                ]
    in
    wrapper []
        [ state.parts
            |> Tuple.first
            |> overlayPart logoIndex
        , state.parts
            |> Tuple.second
            |> overlayPart logoIndex
        ]


overlayPart : Int -> Maybe OverlayPart -> Html Msg
overlayPart logoIndex part =
    part
        |> Maybe.map
            (\{ page, active } ->
                overlayWrapper (renderPage False logoIndex page) active
            )
        |> Maybe.withDefault (overlayWrapper (text "") False)


overlayWrapper : Html msg -> Bool -> Html msg
overlayWrapper child active =
    let
        wrapper =
            styled div
                [ position absolute
                , zIndex
                    (if active then
                        int 80

                     else
                        int 79
                    )
                , top
                    (if active then
                        vh 0

                     else
                        vh 100
                    )
                , left zero
                , width (vw 100)
                , height (vh 100)
                , property "transition" <|
                    if active then
                        "top 0.7s cubic-bezier(0,0,.4,1)"

                    else
                        "top 1s 2s cubic-bezier(0,0,.26,1.29)"
                , overflowY scroll
                , property "-webkit-overflow-scrolling" "touch"
                ]
    in
    wrapper
        [ Html.Styled.Attributes.attribute "data-active"
            (if active then
                "true"

             else
                "false"
            )
        , Html.Styled.Attributes.class "overlay"
        ]
        [ child
        ]


navigationPages : NavigationState -> List NavigationItem -> Route -> Int -> Html Msg
navigationPages navState navItems route logoIndex =
    let
        wrapper =
            styled div
                [ transitions
                    [ { property = "transform"
                      , duration = 0.5
                      , delay = 0.0
                      , easing = "cubic-bezier(0.4, 0.2, 0.2, 1.05)"
                      }
                    ]
                ]
    in
    wrapper [ id "navigation-pages" ]
        (navItems
            |> List.indexedMap (\x y -> ( x, y ))
            |> List.foldr
                (\( index, item ) acc ->
                    List.head acc
                        |> Maybe.map
                            (\( lastIndex, lastItem, lastActive ) ->
                                case navState of
                                    Open openIndex ->
                                        if lastIndex == openIndex then
                                            ( index, item, False ) :: acc

                                        else
                                            ( index, item, lastActive ) :: acc

                                    _ ->
                                        case route of
                                            WagtailRoute _ page ->
                                                if lastItem.active then
                                                    ( index, item, False ) :: acc

                                                else
                                                    ( index, item, lastActive ) :: acc

                                            _ ->
                                                ( index, item, lastActive ) :: acc
                            )
                        |> Maybe.withDefault
                            (( index, item, True ) :: acc)
                )
                []
            |> List.map
                (\( index, item, active ) ->
                    navigationPage navState index item active logoIndex
                )
        )


createTransform : Int -> Int -> Int -> List Style
createTransform x z r =
    let
        value =
            "perspective(1000px) translate3d(0, "
                ++ String.fromInt x
                ++ "vh, "
                ++ String.fromInt z
                ++ "px) "
                ++ "rotateX("
                ++ String.fromInt r
                ++ "deg)"
    in
    [ property "-webkit-transform" value
    , property "-moz-transform" value
    , property "-ms-transform" value
    , property "transform" value
    ]


navigationPage : NavigationState -> Int -> NavigationItem -> Bool -> Int -> Html Msg
navigationPage navState index navItem active logoIndex =
    let
        zoomStart =
            -100

        zoomStep =
            -50

        topStart =
            26

        topStep =
            6

        rotateStart =
            -5

        rotateStep =
            1

        transformStyle =
            case ( active, navState ) of
                ( True, Closed ) ->
                    createTransform
                        0
                        0
                        0

                ( True, Open _ ) ->
                    createTransform
                        (topStart + -index * topStep)
                        (zoomStart + index * zoomStep)
                        0

                ( False, Closed ) ->
                    createTransform
                        (topStart + 50 + -index * topStep)
                        (zoomStart + 340 + index * (Basics.round <| zoomStep * 0.5))
                        (rotateStart + index * rotateStep)

                ( False, Open _ ) ->
                    createTransform
                        (topStart + 70 + -index * topStep)
                        (zoomStart + index * (Basics.round <| zoomStep * 0.5))
                        (rotateStart + index * rotateStep)

                ( _, OpenContact ) ->
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
                , case ( active, navState ) of
                    ( False, Closed ) ->
                        visibility hidden

                    _ ->
                        visibility visible
                , top zero
                , left zero
                , zIndex (int <| 10 - index)
                , transitions
                    [ { property = "transform"
                      , duration = 0.36
                      , delay = 0.0
                      , easing = "cubic-bezier(0.4, 0.2, 0.2, 1.05)"
                      }
                    , { property = "opacity"
                      , duration = 0.5
                      , delay = 0.0
                      , easing = "cubic-bezier(0.4, 0.2, 0.2, 1.05)"
                      }
                    , case ( active, navState ) of
                        ( False, Closed ) ->
                            { property = "visibility"
                            , duration = 0.0
                            , delay = 0.5
                            , easing = "cubic-bezier(0.4, 0.2, 0.2, 1.05)"
                            }

                        _ ->
                            { property = "visibility"
                            , duration = 0.0
                            , delay = 0.0
                            , easing = "cubic-bezier(0.4, 0.2, 0.2, 1.05)"
                            }
                    ]
                , property "-webkit-overflow-scrolling" "touch"
                , overflowX hidden
                , pseudoElement "-webkit-scrollbar"
                    [ display none
                    ]
                , property "-ms-overflow-style" "none"
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
                    ++ (if not active && navState == Closed then
                            [ visibility hidden
                            , opacity zero
                            ]

                        else
                            [ visibility visible
                            , opacity (int 1)
                            ]
                       )
                    ++ transformStyle

        defaultAttributes =
            [ Html.Styled.Attributes.class
                (if active then
                    "active-page"

                 else
                    ""
                )
            ]

        attributes =
            if navState /= Closed then
                [ onMouseOver (NavigationMsg <| UI.State.ChangeNavigation <| Open index)
                , nonAnchorLink navItem.path
                ]
                    ++ defaultAttributes

            else
                defaultAttributes

        emptyView =
            styled div
                [ height (pct 100)
                , width (pct 100)
                , backgroundColor (hex "fff")
                ]
                []
                [ text "" ]
    in
    wrapper attributes
        [ navItem.page
            |> Maybe.map (renderPage False logoIndex)
            |> Maybe.withDefault emptyView
        ]
