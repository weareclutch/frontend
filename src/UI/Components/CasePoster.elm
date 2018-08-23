module UI.Components.CasePoster exposing (view)

import Html.Styled exposing (..)
import Css exposing (..)
import Style exposing (..)
import UI.Common exposing (backgroundImg, addLink)
import Wagtail
import Types exposing (Msg)


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
                , bpMedium
                    [ left (px 40)
                    , bottom (px 40)
                    ]
                , bpLarge
                    [ left (px 40)
                    , bottom (px 60)
                    ]
                , bpXLargeUp
                    [ left (px 270)
                    , bottom (px 100)
                    ]
                ]


        buttonWrapper =
            styled div
                [ position absolute
                , right (px 25)
                , bottom (px 25)
                , bpMedium
                    [ right (px 40)
                    , bottom (px 50)
                    ]
                , bpLarge
                    [ right (px 50)
                    , bottom (px 100)
                    ]
                , bpXLargeUp
                    [ right (px 50)
                    , bottom (px 100)
                    ]
                ]

        title =
            styled h1
                [ maxWidth (px 1200)
                , fontSize (px 40)
                , lineHeight (px 50)
                , letterSpacing (px 2)
                , bpMedium
                    [ fontSize (px 60)
                    , lineHeight (px 70)
                    , letterSpacing (px 3.5)
                    , paddingRight (pct 20)
                    , maxWidth (px 600)
                    ]
                , bpLarge
                    [ fontSize (px 72)
                    , lineHeight (px 80)
                    , letterSpacing (px 6.5)
                    , maxWidth (px 700)
                    ]
                , bpXLargeUp
                    [ fontSize (px 120)
                    , lineHeight (px 130)
                    , letterSpacing (px 8.5)
                    , maxWidth (px 900)
                    ]
                ]

        caption =
            styled span
                [ fontSize (px 26)
                , letterSpacing (px 2)
                ]

    in
        wrapper (wrapperAttributes ++ addLink casePreview.url)
            [ titleWrapper []
                [ title [] [ text casePreview.title ]
                , caption [] [ text casePreview.caption ]
                ]
            , buttonWrapper []
                [ UI.Common.button casePreview.theme [] Nothing
                ]
            ]


