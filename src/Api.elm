module Api exposing (..)

import Http
import Json.Decode as Decode
import Types exposing (..)


siteUrl : String
siteUrl =
    "https://weareclutch.nl"


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
                Http.get url <| decodePageResults decodeCultureContent

            "contact.ContactPage" ->
                Http.get url <| decodePageResults decodeContactContent

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
        Decode.map4 HomeContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "cases" <|
                Decode.list <|
                    Decode.field "value" <|
                        decodeCaseContent
            )
            (Decode.map2 mapCoverContent
                (Decode.field "text" Decode.string)
                (Decode.field "link" Decode.string)
            )
            decodeTheme


mapCoverContent : String -> String -> { text : String, link : String }
mapCoverContent text link =
    { text = text
    , link = link
    }


decodeCultureContent : Decode.Decoder Page
decodeCultureContent =
    Decode.map Culture <|
        Decode.map5 CultureContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "people" <| Decode.list (Decode.field "value" decodePerson))
            (Decode.field "cases" <| Decode.list (Decode.field "value" <| decodeCaseContent))
            (Decode.maybe <| Decode.field "next_event" decodeEvent)
            (Decode.maybe <| Decode.field "ideas" <| Decode.list Decode.string)


decodeEvent : Decode.Decoder Event
decodeEvent =
    Decode.map3 Event
        (Decode.field "date" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.maybe <| Decode.field "image" decodeImage)


decodeCaseContent : Decode.Decoder CaseContent
decodeCaseContent =
    Decode.map8 CaseContent
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "caption" Decode.string)
        (Decode.field "release_date" Decode.string)
        (Decode.field "website_url" Decode.string)
        (Decode.maybe <| Decode.field "body" decodeBlocks)
        (Decode.field "image_src" decodeImage)
        decodeTheme


decodeServicesContent : Decode.Decoder Page
decodeServicesContent =
    Decode.map Services <|
        Decode.map3 ServicesContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "caption" Decode.string)
            (Decode.field "body" <|
                Decode.list <|
                    Decode.field "value" <|
                        Decode.map3
                            (\title ->
                                (\richtext ->
                                    (\services ->
                                        { title = title
                                        , body = richtext
                                        , services = services
                                        }
                                    )
                                )
                            )
                            (Decode.field "title" Decode.string)
                            (Decode.field "richtext" Decode.string)
                            (Decode.field "services" <|
                                Decode.list <|
                                    Decode.map2
                                        (curry (\( text, service ) -> { text = text, service = service }))
                                        (Decode.field "text" Decode.string)
                                        (Decode.field "service" decodeService)
                            )
            )


decodeService : Decode.Decoder Service
decodeService =
    Decode.map3 Service
        (Decode.field "title" Decode.string)
        (Decode.field "body" Decode.string)
        (Decode.field "slides" <| Decode.list decodeImage)


decodeContactContent : Decode.Decoder Page
decodeContactContent =
    Decode.map Contact <|
        Decode.map4 ContactContent
            (Decode.at [ "meta", "type" ] Decode.string)
            (Decode.field "caption" Decode.string)
            (Decode.field "intro" Decode.string)
            (Decode.field "contact_people" <| Decode.list (Decode.field "value" decodePerson))


decodePerson : Decode.Decoder Person
decodePerson =
    Decode.map6 Person
        (Decode.field "first_name" Decode.string)
        (Decode.field "last_name" Decode.string)
        (Decode.field "job_title" Decode.string)
        (Decode.field "photo" decodeImage)
        (Decode.maybe <| Decode.field "email" Decode.string)
        (Decode.maybe <| Decode.field "phone" Decode.string)


decodeImage : Decode.Decoder Image
decodeImage =
    Decode.map2 Image
        (Decode.field "url" Decode.string)
        (Decode.maybe <| Decode.field "caption" Decode.string)


decodeTheme : Decode.Decoder Theme
decodeTheme =
    Decode.map3 Theme
        (Decode.field "background_color" Decode.string)
        (Decode.field "text_color" Decode.string)
        (Decode.maybe <| Decode.map2 (,)
            (Decode.field "background_position_x" Decode.string)
            (Decode.field "background_position_y" Decode.string)
        )

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
