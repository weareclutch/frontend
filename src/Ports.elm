port module Ports exposing (..)

import Types exposing (..)
import Json.Decode as Decode


port getParallaxPositions : (Decode.Value -> msg) -> Sub msg


decodeParallaxPositions : Decode.Value -> Msg
decodeParallaxPositions list =
    let
        decoder =
            Decode.list <|
                Decode.map2
                    (,)
                    (Decode.field "id" Decode.string)
                    (Decode.field "y" Decode.float)

        result =
            Decode.decodeValue decoder list
    in
        case result of
            Ok list ->
                SetParallaxPositions list

            Err _ ->
                SetParallaxPositions []


port setWindowDimensions : ((Float, Float) -> msg) -> Sub msg


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
