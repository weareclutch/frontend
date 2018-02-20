module UI.Common
    exposing
        ( addLink
        , link
        , loremIpsum
        , image
        , backgroundImg
        , parallax
        )

import Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode
import Html.Styled.Attributes exposing (style, src, alt)
import Css exposing (..)
import Api exposing (siteUrl)


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
    in
        case data.caption of
            Just caption ->
                img [ src imageUrl, alt caption ] []

            Nothing ->
                img [ src imageUrl ] []


backgroundImg : Image -> Attribute msg
backgroundImg data =
    let
        imageUrl =
            siteUrl ++ data.image
    in
        css
            [ backgroundImage (url imageUrl)
            , backgroundSize cover
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


parallax : Float -> Float -> Html msg -> Html msg
parallax amount pageScroll element =
    let
        offset =
            (-pageScroll) * amount

        style =
            Html.Styled.Attributes.style
                [ ( "transform", "translate3d(0, " ++ (toString offset) ++ "px, 0)" )
                ]
    in
        div
            [ style
            , class ""
            ]
            [ element
            ]
