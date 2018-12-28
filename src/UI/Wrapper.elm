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
            , overflowX hidden
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
            [ margin4 zero zero (px 32) zero
            , padding zero
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , lineHeight (int 1)
            , fontSize (px 70)
            , letterSpacing (px 3.5)
            , bpLarge
                [ fontSize (px 140)
                , letterSpacing (px 5)
                ]
            , bpXLarge
                [ fontSize (px 140)
                , letterSpacing (px 5)
                ]
            , bpXXLargeUp
                [ fontSize (px 160)
                , letterSpacing (px 8)
                ]
            ]
        , selector "h2"
            [ lineHeight (int 1)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 25) zero
            , padding zero
            , fontSize (px 32)
            , letterSpacing (px 1.5)
            , bpLarge
                [ fontSize (px 80)
                , letterSpacing (px 3)
                , margin4 zero zero (px 32) zero
                ]
            , bpXLarge
                [ fontSize (px 80)
                , letterSpacing (px 3)
                ]
            , bpXXLargeUp
                [ fontSize (px 100)
                , letterSpacing (px 5)
                ]
            ]
        , selector "h3"
            [ lineHeight (int 1)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 15) zero
            , padding zero
            , fontSize (px 26)
            , letterSpacing (px 1.5)
            , bpLarge
                [ fontSize (px 40)
                , margin4 zero zero (px 32) zero
                , letterSpacing (px 2.5)
                ]
            , bpXLarge
                [ fontSize (px 56)
                , letterSpacing (px 3.75)
                ]
            , bpXXLargeUp
                [ fontSize (px 60)
                , letterSpacing (px 4)
                ]
            ]
        , selector "h4"
            [ lineHeight (int 1)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 10) zero
            , padding zero
            , fontSize (px 26)
            , letterSpacing (px 1.5)
            , bpMediumUp
                [ margin4 zero zero (px 32) zero
                ]
            , bpLargeUp
                [ fontSize (px 40)
                , letterSpacing (px 2.5)
                ]
            ]
        , selector "h5"
            [ lineHeight (int 1)
            , letterSpacing (px 2)
            , fontFamilies [ "Qanelas ExtraBold" ]
            , fontWeight (int 400)
            , margin4 zero zero (px 32) zero
            , padding zero
            , fontSize (px 26)
            , letterSpacing (px 1.5)
            , bpLarge
                [ fontSize (px 24)
                , letterSpacing (px 1.5)
                ]
            , bpXLarge
                [ fontSize (px 24)
                , letterSpacing (px 1.5)
                ]
            , bpXXLargeUp
                [ fontSize (px 28)
                , letterSpacing (px 2)
                ]
            ]
        , selector "p"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , margin4 zero zero (px 32) zero
            , padding zero
            , fontSize (px 18)
            , lineHeight (px 26)
            , bpLargeUp
                [ fontSize (px 22)
                , letterSpacing (px 1.5)
                , lineHeight (px 32)
                ]
            ]
        , selector ".intro p, p.intro"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , margin4 zero zero (px 44) zero
            , padding zero
            , fontWeight (int 800)
            , fontSize (px 18)
            , lineHeight (px 26)
            , bpLarge
                [ fontSize (px 24)
                , letterSpacing (px 1.5)
                , lineHeight (px 40)
                ]
            , bpXLarge
                [ fontSize (px 24)
                , letterSpacing (px 1.5)
                , lineHeight (px 40)
                ]
            , bpXXLargeUp
                [ fontSize (px 28)
                , letterSpacing (px 2)
                , lineHeight (px 44)
                ]
            ]
        , selector ".nav, .nav p, p.nav"
            [ fontFamilies [ "Qanelas ExtraBold" ]
            , lineHeight (int 1)
            , fontWeight (int 400)
            , fontSize (px 26)
            , letterSpacing (px 1.5)
            , bpLargeUp
                [ fontSize (px 22)
                , letterSpacing (px 2)
                ]
            ]
        , selector ".tags, .tags p, p.tags"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , fontWeight (int 800)
            , fontSize (px 14)
            , letterSpacing (px 1)
            , lineHeight (px 16)
            , bpLargeUp
                [ fontSize (px 22)
                , letterSpacing (px 1.5)
                , lineHeight (px 32)
                ]
            ]
        , selector "ul, ol"
            [ paddingLeft (px 20)
            , margin4 zero zero (px 35) zero
            ]
        , selector "li"
            [ fontFamilies [ "Roboto", "sans-serif" ]
            , margin4 zero zero (px 32) zero
            , padding zero
            , fontSize (px 18)
            , lineHeight (px 26)
            , bpLargeUp
                [ fontSize (px 22)
                , letterSpacing (px 1.5)
                , lineHeight (px 32)
                ]
            ]
        ]


wrapper : Bool -> List (Html Msg) -> Html Msg
wrapper active children =
    let
        wrapperDiv =
            styled div <|
                [ backgroundColor (hex "001AE0")
                , transition "all" 0.4 0 "ease-in-out"
                , backgroundImage (url "/images/big_c_shadow.png")
                , backgroundSize cover
                , backgroundPosition center
                , if active then
                    opacity (int 1)

                  else
                    opacity zero
                , bpMediumUp
                    [ width (pct 100)
                    , height (pct 100)
                    ]
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
                , width (pct 300)
                , height (pct 300)
                , top (pct -100)
                , zIndex (int 500)
                , bpMedium
                    [ left <| calc (pct -100) minus (px 180)
                    ]
                , bpLargeUp
                    [ left <| calc (pct -100) minus (px 300)
                    ]
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
                                renderPage True page

                            NotFoundRoute _ ->
                                text "page: not found"

                            ErrorRoute ->
                                text "It's not a bug - it's an undocumented feature."
                in
                wrapper (model.route /= UndefinedRoute)
                    [ UI.Components.Navigation.view
                        navigationTree
                        model.navigationState
                        model.route
                        model.contactInformation
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
