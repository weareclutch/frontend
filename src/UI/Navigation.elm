module UI.Navigation exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Events exposing (..)
import Icons.Logo exposing (logo)
import Icons.Menu exposing (burger, cross)
import UI.Common exposing (addLink)
import Style exposing (..)


view : Model -> Html Msg
view model =
    let
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
            styled div
                [ position absolute
                , top (px 12)
                , left (px 6)
                , transition "opacity" 0.2 0 "linear"
                , opacity <|
                    int <|
                        if model.menuState == Closed && model.activeOverlay == Nothing then
                            1
                        else
                            0
                ]

        crossWrapper =
            styled div
                [ transition "opacity" 0.2 0 "linear" , opacity <|
                    int <|
                        if model.menuState /= Closed || model.activeOverlay /= Nothing then
                            1
                        else
                            0
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
            (\menuState ->
                let
                    extraStyle =
                        case menuState of
                            Closed ->
                                [ opacity zero
                                ]

                            _ ->
                                [ opacity (int 1)
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
            (\active ->
                styled li
                    [ display inlineBlock
                    , color (hex "fff")
                    , margin2 zero (px 30)
                    , fontFamilies [ "Qanelas ExtraBold" ]
                    , fontWeight (int 400)
                    , letterSpacing (px 3.5)
                    , fontSize (px 20)
                    , cursor pointer
                    , position relative
                    , hover
                        [ after
                            [ width (pct 100)
                            ]
                        ]
                    , after
                        [ property "content" "''"
                        , backgroundColor (hex "fff")
                        , transition "width" 0.1 0 "ease-in-out"
                        , width <|
                            if active then
                                (pct 100)
                            else
                                (pct 0)
                        , height (px 3)
                        , display block
                        , position relative
                        , bottom (px -4)
                        , margin auto
                        ]
                    ]
            )

        toggleAction =
            if model.activeOverlay == Nothing then
                [ onClick (ToggleMenu) ]
            else
                addLink "/"
    in
        wrapper []
            [ toggleWrapper toggleAction
                [ burgerWrapper [] [ burger ]
                , crossWrapper [] [ cross ]
                ]
            , menuWrapper model.menuState
                []
                [ menuItem
                    (model.activePage
                        |> Maybe.map
                            (\activePage ->
                                activePage == "home.HomePage"
                            )
                        |> Maybe.withDefault False
                    )
                    (addLink "/")
                    [ text "Work" ]
                , menuItem
                    (model.activePage
                        |> Maybe.map
                            (\activePage ->
                                activePage == "contact.ContactPage"
                            )
                        |> Maybe.withDefault False
                    )
                    (addLink "/contact")
                    [ text "Contact" ]
                ]
            , logoWrapper (addLink "/")
                [ logo
                ]
            ]
