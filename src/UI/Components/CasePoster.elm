module UI.Components.CasePoster exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (addLink, backgroundImg)
import Wagtail


view : Wagtail.CasePreview -> Html Msg
view casePreview =
    let
        wrapperAttributes =
            casePreview.backgroundImage
                |> Maybe.map
                    (\image ->
                        [ backgroundImg image ]
                    )
                |> Maybe.withDefault []

        wrapper =
            styled div <|
                [ backgroundColor (hex casePreview.theme.backgroundColor)
                , backgroundPosition center
                , backgroundSize cover
                , position relative
                , cursor pointer
                , top zero
                , left zero
                , overflow hidden
                , maxHeight (pct 100)
                , maxWidth (pct 100)
                , width (pct 100)
                , height auto
                , paddingTop (pct 142.424242)
                ]

        titleWrapper =
            styled div
                [ color (hex casePreview.theme.textColor)
                , position absolute
                , paddingRight (px 40)
                , left (px 25)
                , bottom (px 25)
                , case String.toLower casePreview.theme.textColor of
                    "fff" ->
                        textShadow4 zero (px 15) (px 30) (rgba 0 0 0 0.4)

                    "ffffff" ->
                        textShadow4 zero (px 15) (px 30) (rgba 0 0 0 0.4)

                    _ ->
                        textShadow none
                , bpLargeUp
                    [ left (px 40)
                    , bottom (px 100)
                    ]
                ]

        buttonWrapper =
            styled div
                [ position absolute
                , right (px 20)
                , bottom (px 20)
                , transform <| scale2 0.7 0.7
                , bpLargeUp
                    [ right (px 40)
                    , transforms []
                    , bottom (px 100)
                    ]
                ]

        caption =
            styled h1
                [ maxWidth (px 1200)
                , fontSize (px 28)
                , lineHeight (px 36)
                , letterSpacing (px 2.25)
                , marginBottom (px 10)
                , paddingRight (px 40)
                , bpMediumUp
                    [ paddingRight zero
                    ]
                , bpLargeUp
                    [ fontSize (px 48)
                    , marginBottom (px 35)
                    , lineHeight (px 56)
                    , letterSpacing (px 3.25)
                    , maxWidth (px 400)
                    ]
                ]

        title =
            styled span
                [ fontSize (px 18)
                , letterSpacing (px 2)
                , paddingRight (px 40)
                , bpMediumUp
                    [ paddingRight zero
                    ]
                , bpLargeUp
                    [ fontSize (px 22)
                    , letterSpacing (px 2)
                    ]
                ]
    in
    wrapper (wrapperAttributes ++ addLink casePreview.url)
        [ titleWrapper []
            [ caption [] [ text casePreview.caption ]
            , title [] [ text casePreview.title ]
            ]
        , buttonWrapper []
            [ UI.Common.button casePreview.theme [] Nothing
            ]
        ]
