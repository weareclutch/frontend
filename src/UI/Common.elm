module UI.Common
    exposing
        ( addLink
        , link
        , loremIpsum
        , image
        , backgroundImg
        , parallax
        , button
        )

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode
import Icons.Arrow exposing (arrow)
import Html.Styled.Attributes exposing (style, src, alt)
import Css exposing (..)
import Wagtail exposing (siteUrl)
import Dict exposing (Dict)
import Types exposing (..)
import Wagtail exposing (Theme, Image)


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
        [ (href url), onLinkClick ]


link : String -> List (Html Msg) -> Html Msg
link url children =
    a (addLink url) children


image : Image -> Html msg
image data =
    let
        imageUrl =
            siteUrl ++ data.image

        el =
            styled img
                [ maxWidth (pct 100)
                ]
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


parallax : Dict String Float -> Float -> String -> List (Attribute msg)
parallax dict pageY id =
    Dict.get id dict
        |> Maybe.map
            (\elementY ->
                let
                    offset =
                        (pageY - elementY) * 0.35

                    style =
                        Html.Styled.Attributes.style
                            [ ( "transform", "translate3d(0, " ++ (offset |> floor |> toString) ++ "px, 0)" )
                            , ( "transition", "transform 0.08s linear")
                            ]
                in
                    [ style
                    , class <| "parallax parallax-" ++ id
                    ]
            )
        |> Maybe.withDefault
            [ class <| "parallax parallax-" ++ id
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
                , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.35)
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
                , letterSpacing (px 2)
                , if hasText then
                    padding4 zero (px 60) zero (px 30)
                  else
                    padding zero
                ]

        arrowWrapper =
            styled div
                [ position absolute
                , right (px 23)
                , top (px 21)
                ]
    in
        wrapper attributes
            [ children
            , arrowWrapper [] [ arrow theme.textColor ]
            ]
