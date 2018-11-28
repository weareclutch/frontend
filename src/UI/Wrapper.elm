module UI.Wrapper exposing (view)

import Css exposing (..)
import Css.Foreign exposing (global, selector)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (id)
import Style exposing (..)
import Types exposing (..)
import UI.Components.Contact
import UI.Components.Navigation
import UI.PageWrappers exposing (desktopView, mobileView, navigationPages, overlays, renderPage)


globalStyle : Html msg
globalStyle =
    global
        [ selector "body"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , margin zero
            , padding zero
            , height (vh 100)
            , width (vw 100)
            , fontSize (px 22)
            , lineHeight (px 32)
            , bpMediumUp
                [ overflow hidden
                ]
            ]
        , selector "html"
            [ boxSizing borderBox
            ]
        , selector "*, *:before, *:after"
            [ boxSizing borderBox
            ]
        , selector "#app svg path"
            [ transition "all" 0.16 0 "linear"
            ]
        , selector "h1"
            [ fontSize (px 160)
            , lineHeight (px 160)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , letterSpacing (px 8)
            , margin4 zero zero (px 32) zero
            , padding zero
            ]
        , selector "h2"
            [ fontSize (px 100)
            , lineHeight (px 100)
            , letterSpacing (px 5)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 32) zero
            , padding zero
            ]
        , selector "h3"
            [ fontSize (px 60)
            , lineHeight (px 60)
            , letterSpacing (px 4)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 32) zero
            , padding zero
            ]
        , selector "h4"
            [ fontSize (px 40)
            , lineHeight (px 40)
            , letterSpacing (px 2.5)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 32) zero
            , padding zero
            ]
        , selector "h5"
            [ fontSize (px 28)
            , lineHeight (px 28)
            , letterSpacing (px 2)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 32) zero
            , padding zero
            ]
        , selector "p"
            [ fontSize (px 22)
            , lineHeight (px 32)
            , fontFamilies [ "Roboto", "sans-serif" ]
            , margin4 zero zero (px 32) zero
            , padding zero
            , letterSpacing (px 1.5)
            ]
        , selector ".intro p, p.intro"
            [ fontSize (px 28)
            , lineHeight (px 44)
            , fontFamilies [ "Roboto", "sans-serif" ]
            , fontWeight (int 500)
            , margin4 zero zero (px 44) zero
            , padding zero
            , letterSpacing (px 2)
            ]
        , selector "ul"
            [ paddingLeft (px 20)
            , margin4 zero zero (px 35) zero
            ]
        , selector "li"
            [ fontSize (px 18)
            , lineHeight (px 28)
            , fontFamilies [ "Roboto", "sans-serif" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 6) zero
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

        animationWrapper =
            styled div
                [ position relative
                , height (vh 100)
                , width (vw 100)
                , display none
                ]

        bg =
            styled div
                [ position absolute
                , width (pct 200)
                , height (pct 200)
                , left <| calc (pct -50) minus (vw 20)
                , top (pct -50)
                , zIndex (int 500)
                ]

        effects =
            styled div
                [ position absolute
                , width (pct 200)
                , height (pct 200)
                , left <| calc (pct -50) minus (vw 20)
                , top (pct -50)
                , zIndex (int 510)
                ]

        tagLine =
            styled div
                [ position absolute
                , width (vw 100)
                , height (vh 100)
                , maxWidth (px 1400)
                , margin auto
                , left (pct 50)
                , transform <| translateX (pct -50)
                , top zero
                , zIndex (int 520)
                ]
    in
    div []
        [ globalStyle
        , animationWrapper [ id "animation-wrapper" ]
            [ bg [ id "bg" ] []
            , effects [ id "effects" ] []
            , tagLine [ id "tagline" ] []
            ]
        , wrapperDiv [ id "app" ] children
        ]


view : Model -> Html Msg
view model =
    model.navigationTree
        |> Maybe.map
            (\navigationTree ->
                let
                    mobilePage =
                        case model.route of
                            UndefinedRoute ->
                                text "page: undefined route"

                            WagtailRoute _ page ->
                                renderPage page

                            NotFoundRoute _ ->
                                text "page: not found"

                            ErrorRoute ->
                                text "It's not a bug - it's an undocumented feature."
                in
                wrapper (model.route /= UndefinedRoute)
                    [ UI.Components.Navigation.view navigationTree model.navigationState model.route
                    , desktopView <|
                        overlays model.overlayState
                    , desktopView <|
                        navigationPages model.navigationState navigationTree.items model.route
                    , desktopView <|
                        (Maybe.map
                            UI.Components.Contact.view
                            model.contactInformation
                            |> Maybe.withDefault
                                (text "")
                        )
                    , mobileView <|
                        mobilePage
                    ]
            )
        |> Maybe.withDefault
            (wrapper False [])
