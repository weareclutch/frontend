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
                Http.get url decodeHomeContent

            "case.CasePage" ->
                Http.get url <| decodePageResults decodeCaseContent

            "service.ServicesPage" ->
                Http.get url <| decodePageResults decodeServicesContent
            
            "culture.CulturePage" ->
                Http.get url <| decodePageResults decodeServicesContent

            "contact.ContactPage" ->
                Http.get url <| decodePageResults decodeServicesContent

            _ ->
                Http.get (apiUrl ++ "/pages/") decodeServicesContent



decodePageResults : Decode.Decoder Page -> Decode.Decoder Page
decodePageResults decoder =
    Decode.field "items" <|
        Decode.index 0 <|
            decoder


decodeHomeContent : Decode.Decoder Page
decodeHomeContent =
    Decode.map Home <|
        Decode.map HomeContent <|
            Decode.field "cases" <|
                Decode.list <|
                    Decode.field "value" <|
                        decodeCaseContent


decodeCaseContent : Decode.Decoder Page
decodeCaseContent =
    Decode.map2 Case
        (Decode.field "id" Decode.int)
        (Decode.map4 CaseContent
            (Decode.field "caption" Decode.string)
            (Decode.field "release_date" Decode.string)
            (Decode.field "website_url" Decode.string)
            (Decode.maybe <| Decode.field "body" decodeBlocks)
        )


decodeServicesContent : Decode.Decoder Page
decodeServicesContent =
    Decode.map Services <|
        Decode.map ServicesContent
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
        
  
