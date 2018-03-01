port module Ports exposing (..)

import Types exposing (..)
import Json.Decode as Decode


port showHomeIntro : Maybe String -> Cmd msg


port getCasePosition : Int -> Cmd msg


port newCasePosition : (Decode.Value -> msg) -> Sub msg


port repositionCase : (Decode.Value -> msg) -> Sub msg


decodePosition : (( Float, Float ) -> Msg) -> Decode.Value -> Msg
decodePosition message position =
    let
        decoder =
            Decode.map2 (,)
                (Decode.field "left" Decode.float)
                (Decode.field "top" Decode.float)

        result =
            Decode.decodeValue decoder position
    in
        case result of
            Ok pos ->
                message pos

            Err _ ->
                message ( 0, 0 )


port setScrollPosition : (Float -> msg) -> Sub msg


port changeMenu : (String -> msg) -> Sub msg


decodeDirection : String -> Msg
decodeDirection direction =
    case direction of
        "top" ->
            OpenMenu OpenTop

        "bottom" ->
            OpenMenu OpenBottom

        "close" ->
            OpenMenu Closed

        _ ->
            OpenMenu OpenTop
