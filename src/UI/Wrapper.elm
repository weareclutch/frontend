module UI.Wrapper exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Css.Foreign exposing (global, selector)
import Style exposing (..)
import UI.State
import UI.Components.Navigation
import UI.Components.Contact
import UI.PageWrappers


globalStyle : Html msg
globalStyle =
    global
        [ selector "body"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , margin zero
            , padding zero
            , overflow hidden
            , height (vh 100)
            , width (vw 100)
            ]
        , selector "html"
            [ boxSizing borderBox
            ]
        , selector "*, *:before, *:after"
            [ boxSizing borderBox
            ]
        , selector "svg path"
            [ transition "all" 0.16 0 "linear"
            ]
        , selector "h1"
            [ fontSize (px 120)
            , lineHeight (px 130)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , letterSpacing (px 8.4)
            , margin4 zero zero (px 35) zero
            , padding zero
            ]
        , selector "h2"
            [ fontSize (px 50)
            , lineHeight (px 60)
            , letterSpacing (px 3.5)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 35) zero
            , padding zero
            ]
        , selector "p"
            [ fontSize (px 22)
            , lineHeight (px 34)
            , fontFamilies [ "Roboto", "sans-serif" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 35) zero
            , padding zero
            , letterSpacing (px 2)
            ]
        ]


wrapper : Bool -> List (Html Msg) -> Html Msg
wrapper active children =
    let
        wrapperDiv =
            styled div <|
                [ backgroundColor (hex "001AE0")
                , transition "all" 0.4 0 "ease-in-out"
                , width (pct 100)
                , height (pct 100)
                , if active then
                    opacity (int 1)
                else
                    opacity zero
                ]

    in
        globalStyle
            :: children
            |> wrapperDiv []


view : Model -> Html Msg
view model =
    model.navigationTree
        |> Maybe.map
            (\navigationTree ->
                let
                    (overlayState, overlayPage) =
                        case model.route of
                            UndefinedRoute ->
                                (False, text "overlay: undefined route")

                            WagtailRoute page -> 
                                case UI.State.isNavigationPage navigationTree page of
                                    True ->
                                        (False, text "overlay: is nav page")

                                    False ->
                                        (model.navigationState == UI.State.Closed, UI.PageWrappers.renderPage page)

                            NotFoundRoute ->
                                (False, text "overlay: not found")

                    overlay =
                        UI.PageWrappers.overlayWrapper overlayPage overlayState

                in
                    wrapper (model.route /= UndefinedRoute)
                        [ UI.Components.Navigation.view navigationTree model.navigationState model.route
                        , overlay
                        , UI.PageWrappers.navigationPages model.navigationState navigationTree.items model.route
                        , UI.Components.Contact.view
                        ]
            )
        |> Maybe.withDefault
            ( wrapper False [] )

