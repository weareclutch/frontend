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


getUrlAndDecoder : PageType -> Maybe Int -> ( String, Decode.Decoder Page )
getUrlAndDecoder pageType id =
    let
        ( typeString, decoder ) =
            case pageType of
                Home ->
                    ( "home.HomePage", decodeHomeContent )

                Case ->
                    ( "case.CasePage", decodeCaseContent )

                Services ->
                    ( "service.ServicesPage", decodeServicesContent )

                Culture ->
                    ( "culture.CulturePage", decodeServicesContent )

                Contact ->
                    ( "contact.ContactPage", decodeServicesContent )

        url =
            case id of
                Just id ->
                    apiUrl ++ "/pages/?type=" ++ typeString ++ "&fields=*" ++ "&id=" ++ (toString id)

                Nothing ->
                    apiUrl ++ "/pages/?type=" ++ typeString ++ "&fields=*"
    in
        ( url, decodePageResults decoder )


getPage : PageType -> Http.Request Page
getPage pageType =
    let
        ( url, decoder ) =
            getUrlAndDecoder pageType Nothing
    in
        Http.get url decoder


getPageById : PageType -> Int -> Http.Request Page
getPageById pageType id =
    let
        ( url, decoder ) =
            getUrlAndDecoder pageType <| Just id
    in
        Http.get url decoder


decodePageResults : Decode.Decoder ContentType -> Decode.Decoder Page
decodePageResults decoder =
    Decode.field "items" <|
        Decode.index 0 <|
            decodePage decoder


decodePage : Decode.Decoder ContentType -> Decode.Decoder Page
decodePage decoder =
    Decode.map4 Page
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.at [ "meta", "type" ] decodePageType)
        decoder


decodePageType : Decode.Decoder PageType
decodePageType =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "home.HomePage" ->
                        Decode.succeed Home

                    "case.CasePage" ->
                        Decode.succeed Case

                    "service.ServicesPage" ->
                        Decode.succeed Services

                    "culture.CulturePage" ->
                        Decode.succeed Culture

                    "contact.ContactPage" ->
                        Decode.succeed Contact

                    _ ->
                        Decode.fail "Unknown page type"
            )


decodeHomeContent : Decode.Decoder ContentType
decodeHomeContent =
    Decode.map HomeContentType <|
        Decode.map HomeContent <|
            Decode.field "cases" <|
                Decode.list <|
                    Decode.field "value" <|
                        decodePage decodeCaseContent


decodeCaseContent : Decode.Decoder ContentType
decodeCaseContent =
    Decode.map CaseContentType <|
        Decode.map3 CaseContent
            (Decode.field "caption" Decode.string)
            (Decode.field "release_date" Decode.string)
            (Decode.field "website_url" Decode.string)


decodeServicesContent : Decode.Decoder ContentType
decodeServicesContent =
    Decode.map ServicesContentType <|
        Decode.map ServicesContent
            (Decode.field "caption" Decode.string)
