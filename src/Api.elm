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
            Http.get url (decodePageResults decodeHomeContent)


getCasePage : Int -> Cmd Msg
getCasePage id =
    let
        url =
            apiUrl ++ "/pages/" ++ (toString id)
    in
        Http.send AddPage <|
            Http.get url (decodePage decodeCaseContent)


decodePage : Decode.Decoder ContentType -> Decode.Decoder Page
decodePage decoder =
    Decode.map3 Page
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        decoder


decodePageResults : Decode.Decoder ContentType -> Decode.Decoder Page
decodePageResults decoder =
    Decode.field "items" <|
        Decode.index 0 <|
            decodePage decoder


decodeHomeContent : Decode.Decoder ContentType
decodeHomeContent =
    Decode.map HomePage <|
        Decode.map HomeContent <|
            Decode.field "cases" <|
                Decode.list <|
                    Decode.at [ "value", "url" ] Decode.string


decodeCaseContent : Decode.Decoder ContentType
decodeCaseContent =
    Decode.map CasePage <|
        Decode.map3 CaseContent
            (Decode.field "caption" Decode.string)
            (Decode.field "release_date" Decode.string)
            (Decode.field "website_url" Decode.string)

