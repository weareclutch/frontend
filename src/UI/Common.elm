module UI.Common exposing
    ( addLink
    , backgroundImg
    , button
    , image
    , link
    , loremIpsum
    , siteMargins
    , slideshow
    )

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, src, alt, href)
import Html.Styled.Events exposing (..)
import Icons.Arrow exposing (arrow)
import Json.Decode as Decode
import Style exposing (..)
import Types exposing (..)
import Wagtail exposing (Image, Theme, siteUrl)


addLink : String -> List (Attribute Msg)
addLink url =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }

        message =
            ChangeLocation url

        onLinkClick =
            onWithOptions "click" options (Decode.succeed message)
    in
    [ href url, onLinkClick ]


link : String -> List (Html Msg) -> Html Msg
link url children =
    a (addLink url) children


image : List Style -> Image -> Html msg
image styles data =
    let
        imageUrl =
            siteUrl ++ data.image

        el =
            styled img styles
    in
    case data.caption of
        Just caption ->
            el [ src imageUrl, alt caption ] []

        Nothing ->
            el [ src imageUrl ] []


backgroundImg : Image -> Attribute msg
backgroundImg data =
    let
        imageUrl =
            siteUrl ++ data.image
    in
    css
        [ backgroundImage (url imageUrl)
        , backgroundRepeat noRepeat
        ]


loremIpsum : Html msg
loremIpsum =
    styled p
        [ maxWidth (px 600)
        ]
        []
        [ text
            """
               Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer porta mi nec sagittis rutrum. Mauris sodales, dui vel finibus eleifend, lacus ex porta mi, a egestas nisl lectus at purus. Quisque eu nunc ut lectus luctus sagittis. Vivamus rhoncus, elit non placerat sagittis, arcu risus aliquet enim, eget mollis justo dui vitae felis. Sed accumsan eu quam et facilisis. Etiam tempus finibus magna in consectetur. Phasellus in magna vel dolor viverra laoreet ac eget enim. Vivamus ut neque non odio cursus pulvinar. Phasellus semper quis quam sit amet imperdiet. Curabitur dictum orci risus, at cursus lorem pharetra ac. Ut sit amet augue feugiat, elementum sem non, dignissim lectus. Curabitur vitae aliquet enim, a elementum ipsum. Aliquam eu massa est. Donec mollis dui bibendum accumsan sollicitudin.

               Nulla vitae tincidunt massa. Cras sagittis magna a turpis consequat, sit amet interdum odio porta. Morbi mattis mollis turpis vitae consequat. Phasellus justo enim, consectetur a neque mollis, congue viverra est. Praesent molestie mattis libero, ut auctor sem tristique ac. Donec vitae libero eu sem mollis eleifend id vel nisi. Curabitur justo elit, iaculis sit amet libero quis, dignissim vulputate libero.

           Phasellus et sapien quis tellus ultrices mattis. Sed viverra dolor at augue efficitur iaculis. Nam ultricies luctus dui sed tempus. Nam mattis tempus pretium. Sed sed quam fringilla ante euismod rhoncus. Nam magna mauris, interdum in aliquet non, imperdiet sed nibh. Nulla ut faucibus lacus, at euismod tortor. Suspendisse ac bibendum eros.
          """
        ]


siteMargins : List (Attribute msg) -> List (Html msg) -> Html msg
siteMargins =
    styled div
        [ position relative
        , margin2 zero (px 25)
        , bpMedium
            [ margin2 zero (px 80)
            ]
        , bpLarge
            [ margin2 zero (px 140)
            ]
        , bpXLargeUp
            [ margin2 zero (px 280)
            ]
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
                , transition "all" 0.16 0 "linear"
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
                , top (px 21)
                ]
    in
    wrapper attributes
        [ children
        , arrowWrapper [] [ arrow theme.textColor ]
        ]


slideshow : String -> (Float, Float, Float) -> (a -> Html Msg) -> List a -> Html Msg
slideshow id (fXLarge, fLarge, fMedium) render slides =
    let
        numSlides = toFloat <| List.length slides
        totalScreensXLarge = numSlides / fXLarge
        totalScreensLarge = numSlides / fLarge
        totalScreensMedium = numSlides / fMedium

        outerWrapper =
            styled div
                [ position relative
                , width (pct 100)
                ]

        wrapper =
            styled div
                [ position relative
                , overflowX scroll
                , width (pct 100)
                , marginBottom (px 40)
                , bpMediumUp
                    [ overflowX hidden
                    ]
                ]

        wrapperInner =
            styled div
                [ position relative
                , width
                    <| pct
                    <| numSlides * 100
                , paddingLeft (px 25)
                , bpMedium
                    [ width
                        <| pct
                        <| totalScreensMedium * 100
                    , paddingLeft (px 80)
                    ]
                , bpLarge
                    [ width
                        <| pct
                        <| totalScreensLarge * 100
                    , paddingLeft (px 140)
                    ]
                , bpXLargeUp
                    [ width
                        <| pct
                        <| totalScreensXLarge * 100
                    , paddingLeft (px 280)
                    ]
                ]


        slide =
            styled div
                [ display inlineBlock
                , width 
                    <| pct
                    <| 100 / numSlides
                , bpMedium
                    [ width
                        <| pct
                        <| 100 / fMedium / totalScreensMedium
                    ]
                , bpLarge
                    [ width
                        <| pct
                        <| 100 / fLarge / totalScreensLarge
                    ]
                , bpXLargeUp
                    [ width
                        <| pct
                        <| 100 / fXLarge / totalScreensXLarge
                    ]
                ]

        controls =
            styled div
                [ position absolute
                , bottom (px -30)
                , left zero
                , width (pct 100)
                , textAlign right
                , display none
                , bpMediumUp
                    [ display block
                    ]
                ]

        button =
            styled div
                [ width (px 60)
                , height (px 60)
                , backgroundColor (hex "001AE0")
                , display inlineBlock
                , marginLeft (px 25)
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
                    , top (px 21)
                    , transform 
                        <| rotate
                        <| if rotated then
                            (deg 180)
                        else
                            (deg 0)
                    ]

    in
        outerWrapper []
            [ wrapper
                [ Html.Styled.Attributes.id id
                ]
                [ wrapperInner []
                    ( List.map
                        (\s -> slide [] [ render s ])
                        slides
                    )
                ]
            , controls []
                [ siteMargins []
                    [ button
                        [ onClick (UpdateSlideshow id Left)
                        ]
                        [ arrowWrapper True [] [ arrow "ffffff" ]
                        ]
                    , button
                        [ onClick (UpdateSlideshow id Right)
                        ]
                        [ arrowWrapper False [] [ arrow "ffffff" ]
                        ]
                    ]
                ]
            ]


