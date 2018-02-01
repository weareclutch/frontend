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


getPage : String -> Http.Request Page
getPage pageType =
    getPageRequest pageType Nothing


getPageById : String -> Int -> Http.Request Page
getPageById pageType id =
    getPageRequest pageType (Just id)


getPageRequest : String -> Maybe Int -> Http.Request Page
getPageRequest pageType id =
    let
        url =
            case id of
                Just id ->
                    apiUrl ++ "/pages/?type=" ++ pageType ++ "&fields=*" ++ "&id=" ++ (toString id)

                Nothing ->
                    apiUrl ++ "/pages/?type=" ++ pageType ++ "&fields=*"
    in
        case pageType of
            "home.HomePage" ->
                Http.get url <| decodePageResults decodeHomeContent

            "service.ServicesPage" ->
                Http.get url <| decodePageResults decodeServicesContent

            "culture.CulturePage" ->
                Http.get url <| decodePageResults decodeServicesContent

            "contact.ContactPage" ->
                Http.get url <| decodePageResults decodeServicesContent

            _ ->
                Http.get (apiUrl ++ "/pages/") decodeServicesContent


getCaseById : Int -> Http.Request CaseContent
getCaseById id =
    let
        url =
            apiUrl ++ "/pages/?type=case.CasePage&fields=*" ++ "&id=" ++ (toString id)
    in
        Http.get url <| decodePageResults decodeCaseContent


decodePageResults : Decode.Decoder a -> Decode.Decoder a
decodePageResults decoder =
    Decode.field "items" <|
        Decode.index 0 <|
            decoder


decodeHomeContent : Decode.Decoder Page
decodeHomeContent =
    Decode.map Home <|
        Decode.map2 HomeContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "cases" <|
                Decode.list <|
                    Decode.field "value" <|
                        decodeCaseContent
            )


decodeCaseContent : Decode.Decoder CaseContent
decodeCaseContent =
    Decode.map6 CaseContent
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "caption" Decode.string)
        (Decode.field "release_date" Decode.string)
        (Decode.field "website_url" Decode.string)
        (Decode.maybe <| Decode.field "body" decodeBlocks)


decodeServicesContent : Decode.Decoder Page
decodeServicesContent =
    Decode.map Services <|
        Decode.map2 ServicesContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "caption" Decode.string)


decodeBlocks : Decode.Decoder (List Block)
decodeBlocks =
    Decode.list <|
        Decode.field "value" <|
            Decode.oneOf
                [ decodeRichText
                , decodeQuote
                ]


decodeRichText : Decode.Decoder Block
decodeRichText =
    Decode.string
        |> Decode.andThen
            (\string ->
                Decode.succeed <| RichTextBlock string
            )


decodeQuote : Decode.Decoder Block
decodeQuote =
    Decode.map2 Quote
        (Decode.field "text" Decode.string)
        (Decode.maybe <| Decode.field "name" Decode.string)
        |> Decode.andThen
            (\quote ->
                Decode.succeed <| QuoteBlock quote
            )
