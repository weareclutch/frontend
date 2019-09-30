module UI.Common exposing
    ( backgroundImg
    , button
    , container
    , image
    , nonAnchorLink
    , siteMargins
    , slideshow
    )

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (alt, css, href, src)
import Html.Styled.Events exposing (..)
import Icons.Arrow exposing (arrow)
import Json.Decode as Decode
import Style exposing (..)
import Types exposing (..)
import Wagtail exposing (Image, Theme)


nonAnchorLink : String -> Attribute Msg
nonAnchorLink url =
    onClick <| NavigateToUrl url


image : List Style -> Image -> Html msg
image styles data =
    let
        el =
            styled img styles
    in
    case data.caption of
        Just caption ->
            el [ src data.image, alt caption ] []

        Nothing ->
            el [ src data.image ] []


backgroundImg : Image -> Attribute msg
backgroundImg data =
    css
        [ backgroundImage (url data.image)
        , backgroundRepeat noRepeat
        ]


siteMargins : List (Attribute msg) -> List (Html msg) -> Html msg
siteMargins =
    styled div
        [ position relative
        , margin2 zero (px 25)
        , bpMedium
            [ margin2 zero (px 80)
            ]
        , bpLargeUp
            [ margin2 zero (px 140)
            ]
        ]


container : List (Attribute msg) -> List (Html msg) -> Html msg
container =
    styled div
        [ position relative
        , maxWidth (px 1800)
        , margin auto

        -- , border3 (px 1) solid (hex "f0f")
        ]


button : Theme -> List (Attribute msg) -> Maybe String -> Html msg
button theme attributes maybeText =
    let
        ( hasText, children ) =
            case maybeText of
                Just txt ->
                    ( True, text txt )

                Nothing ->
                    ( False, text "" )

        wrapper =
            styled div
                [ cursor pointer
                , backgroundColor (hex theme.backgroundColor)
                , color (hex theme.textColor)
                , borderRadius (px 60)
                , display inlineBlock
                , minHeight (px 60)
                , minWidth (px 60)
                , lineHeight (px 60)
                , position relative
                , fontSize (px 22)
                , fontWeight (int 500)
                , transition "box-shadow" 0.16 0 "linear"
                , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.15)
                , letterSpacing (px 2)
                , if hasText then
                    padding4 zero (px 60) zero (px 30)

                  else
                    padding zero
                , hover
                    [ boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.35)
                    ]
                ]

        arrowWrapper =
            styled div
                [ position absolute
                , right (px 24)
                , top zero
                ]
    in
    wrapper attributes
        [ children
        , arrowWrapper [] [ arrow theme.textColor ]
        ]


slideshow : String -> ( Float, Float, Float ) -> (a -> Html Msg) -> List a -> Html Msg
slideshow id ( fXLarge, fLarge, fMedium ) render slides =
    let
        numSlides =
            toFloat <| List.length slides

        totalScreensXLarge =
            numSlides / fXLarge

        totalScreensLarge =
            numSlides / fLarge

        totalScreensMedium =
            numSlides / fMedium

        outerWrapper =
            styled div
                [ position relative
                , width (pct 100)
                ]

        wrapper =
            styled div
                [ position relative
                , overflowX scroll
                , property "-webkit-overflow-scrolling" "touch"
                , width (pct 100)
                , bpMediumUp
                    [ overflowX hidden
                    ]
                ]

        wrapperInner =
            styled div
                [ position relative
                , displayFlex
                , width <|
                    pct <|
                        numSlides
                            * 70
                , paddingLeft (px 25)
                , bpMedium
                    [ width <|
                        pct <|
                            totalScreensMedium
                                * 100
                    , paddingLeft (px 80)
                    ]
                , bpLarge
                    [ width <|
                        pct <|
                            totalScreensLarge
                                * 100
                    , paddingLeft (px 140)
                    ]
                , bpXLarge
                    [ width <|
                        pct <|
                            totalScreensLarge
                                * 100
                    , paddingLeft (px 140)
                    ]
                , bpXXLargeUp
                    [ width <|
                        pct <|
                            totalScreensXLarge
                                * 100
                    , property "padding-left" "calc((100vw - 1520px) / 2)"
                    ]
                ]

        slide =
            styled div
                [ display inlineBlock
                , width <|
                    pct <|
                        100
                            / numSlides
                , bpMedium
                    [ width <|
                        pct <|
                            100
                                / fMedium
                                / totalScreensMedium
                    ]
                , bpLarge
                    [ width <|
                        pct <|
                            100
                                / fLarge
                                / totalScreensLarge
                    ]
                , bpXLargeUp
                    [ width <|
                        pct <|
                            100
                                / fXLarge
                                / totalScreensXLarge
                    ]
                ]

        controls =
            \visible ->
                styled div
                    [ position absolute
                    , bottom (px -30)
                    , left zero
                    , width (pct 100)
                    , textAlign right
                    , display none
                    , bpMediumUp
                        [ if visible then
                            display block

                          else
                            display none
                        ]
                    ]

        slideshowButton =
            styled div
                [ width (px 60)
                , height (px 60)
                , backgroundColor (hex "001AE0")
                , display inlineBlock
                , marginLeft (px 10)
                , cursor pointer
                , borderRadius (pct 50)
                , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.5)
                , position relative
                ]

        arrowWrapper =
            \rotated ->
                styled div
                    [ position absolute
                    , right (px 24)
                    , top (px 21.5)
                    , fontSize (px 0)
                    , lineHeight (px 0)
                    , transform <|
                        scaleX <|
                            if rotated then
                                -1

                            else
                                1
                    ]
    in
    outerWrapper []
        [ wrapper
            [ Html.Styled.Attributes.class id
            ]
            [ wrapperInner []
                (List.map
                    (\s -> slide [] [ render s ])
                    slides
                )
            ]
        , controls (List.length slides > 1)
            []
            [ siteMargins []
                [ slideshowButton
                    [ onClick (UpdateSlideshow id Left)
                    ]
                    [ arrowWrapper True [] [ arrow "ffffff" ]
                    ]
                , slideshowButton
                    [ onClick (UpdateSlideshow id Right)
                    ]
                    [ arrowWrapper False [] [ arrow "ffffff" ]
                    ]
                ]
            ]
        ]
