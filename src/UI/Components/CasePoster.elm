module UI.Components.CasePoster exposing (view)

import Css exposing (..)
import Css.Global
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, href)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (backgroundImg)
import Wagtail


view : Wagtail.CasePreview -> Html Msg
view casePreview =
    let
        imageAttributes =
            casePreview.backgroundImage
                |> Maybe.map
                    (\image ->
                        [ class "image"
                        , backgroundImg image
                        ]
                    )
                |> Maybe.withDefault [ class "image" ]

        wrapper =
            styled a
                [ backgroundColor (hex casePreview.theme.backgroundColor)
                , position relative
                , overflow hidden
                , cursor pointer
                , top zero
                , left zero
                , display block
                , maxHeight (pct 100)
                , maxWidth (pct 100)
                , width (pct 100)
                , height (pct 100)
                , transition "all" 0.16 0 "linear"
                , hover
                    [ Css.Global.descendants
                        [ Css.Global.typeSelector ".image"
                            [ transform <| scale 1.03
                            ]
                        ]
                    ]
                ]

        imageWrapper =
            styled div
                [ height (pct 100)
                , width (pct 180)
                , left (pct -40)
                , position relative
                ]

        imageEl =
            styled div
                [ backgroundPosition center
                , backgroundSize cover
                , position absolute
                , top zero
                , left zero
                , width (pct 100)
                , height (pct 100)
                , transition "all" 0.26 0 "ease-in-out"
                , transform <| scale 1.01
                , bpMediumUp
                    [ left (px -150)
                    ]
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
            styled h3
                [ maxWidth (px 1200)
                , marginBottom (px 10)
                , paddingRight (px 40)
                , bpMediumUp
                    [ paddingRight zero
                    ]
                , bpLargeUp
                    [ marginBottom (px 35)
                    , maxWidth (px 400)
                    ]
                ]

        title =
            styled div
                [ paddingRight (px 40)
                , bpMediumUp
                    [ paddingRight zero
                    ]
                ]
    in
    wrapper
        [ href casePreview.url ]
        [ imageWrapper [ class "image-wrapper" ]
            [ imageEl imageAttributes []
            ]
        , titleWrapper []
            [ caption [] [ text casePreview.caption ]
            , title [] [ text casePreview.title ]
            ]
        , buttonWrapper []
            [ UI.Common.button casePreview.theme [] Nothing
            ]
        ]
