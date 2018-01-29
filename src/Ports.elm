port module Ports exposing (getCasePosition, newCasePosition, decodePosition)

import Types exposing (..)
import Json.Decode as Decode


port getCasePosition : Int -> Cmd msg


port newCasePosition : (Decode.Value -> msg) -> Sub msg


decodePosition : Decode.Value -> Msg
decodePosition position =
    let
        decoder =
            Decode.map2 (,)
                (Decode.field "x" Decode.int)
                (Decode.field "y" Decode.int)

        result =
            Decode.decodeValue decoder position
    in
        case result of
            Ok pos ->
                SetCasePosition pos

            Err _ ->
                SetCasePosition ( 0, 0 )
