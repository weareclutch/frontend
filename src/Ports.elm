port module Ports exposing (..)

import Types exposing (..)
import Json.Decode as Decode


port getCasePosition : Int -> Cmd msg


port newCasePosition : (Decode.Value -> msg) -> Sub msg


decodePosition : Decode.Value -> Msg
decodePosition position =
    let
        decoder =
            Decode.map2 (,)
                (Decode.field "x" Decode.float)
                (Decode.field "y" Decode.float)

        result =
            Decode.decodeValue decoder position
    in
        case result of
            Ok pos ->
                SetCasePosition pos

            Err _ ->
                SetCasePosition ( 0, 0 )


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
