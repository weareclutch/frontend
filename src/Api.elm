module Api exposing (..)

import Http
import Json.Decode as Decode
import Types exposing (..)


siteUrl : String
siteUrl =
    "http://127.0.0.1:8000"


apiUrl : String
apiUrl =
    siteUrl ++ "/api/v2"


getHomePage : Cmd Msg
getHomePage =
    let
        url =
            apiUrl ++ "/pages/?type=home.HomePage&fields=*"
    in
        Http.send AddPage <|
            Http.get url decodePageResults


getCasePage : Int -> Cmd Msg
getCasePage id =
    let
        url =
            apiUrl ++ "/pages/" ++ (toString id)
    in
        Http.send AddPage <|
            Http.get url decodePage


decodePage : Decode.Decoder Page
decodePage =
    Decode.map2 Page
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)


decodePageResults : Decode.Decoder Page
decodePageResults =
    Decode.field "items" <|
        Decode.index 0 <|
            decodePage
