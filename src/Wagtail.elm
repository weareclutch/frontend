module Wagtail exposing (..)

import Http exposing (..)
import Navigation
import Json.Decode as D
import Date exposing (Date)


siteUrl : String
siteUrl =
    "http://staging.weareclutch.nl"


apiUrl : String
apiUrl =
    siteUrl ++ "/api/v2"


type Msg
    = LoadPage (Result Http.Error Page)
    | PreloadPage (Result Http.Error Page)


type Page
    = HomePage HomePageContent
    | CasePage CasePageContent


getPageId : Page -> Int
getPageId page =
    case page of
        HomePage { meta } -> meta.id
        CasePage { meta } -> meta.id


getPageTheme : Page -> Theme
getPageTheme page =
    case page of
        HomePage { theme } -> theme
        CasePage { theme } -> theme


getWagtailPage : Navigation.Location -> Cmd Msg
getWagtailPage location =
    Http.request
        { method = "GET"
        , headers = [header "Accept" "application/json"]
        , url = apiUrl ++ "/pages/find/?html_path=" ++ location.pathname
        , body = Http.emptyBody
        , expect = expectJson (
            decodePageType
                |> D.andThen getPageDecoder
        )
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send LoadPage


preloadWagtailPage : String -> Cmd Msg
preloadWagtailPage path =
    Http.request
        { method = "GET"
        , headers = [header "Accept" "application/json"]
        , url = apiUrl ++ "/pages/find/?html_path=" ++ path
        , body = Http.emptyBody
        , expect = expectJson (
            decodePageType
                |> D.andThen getPageDecoder
        )
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send PreloadPage


decodePageType : D.Decoder String
decodePageType =
    D.at ["meta", "type"] D.string


getPageDecoder : String -> D.Decoder Page
getPageDecoder pageType =
  case pageType of
    -- Register the page decoders here ( "page.Type" -> aDecoder ) --
    "home.HomePage" -> homePageDecoder
    "case.CasePage" -> casePageDecoder

    -- Default handler forn unknown types (aka "we can't handle")  --
    _ -> D.fail ("Can't find decoder for \"" ++ pageType ++ "\" type")


dateDecoder : D.Decoder Date
dateDecoder  =
    D.string
        |> D.andThen ( \s -> D.succeed (Date.fromString s |> Result.withDefault (Date.fromTime 0)))


type alias WagtailMetaContent =
    { id : Int
    , title : String
    , type_ : String
    , slug : String
    , published : Date
    , seoTitle : String
    }


metaDecoder : D.Decoder WagtailMetaContent
metaDecoder =
    D.map6 WagtailMetaContent
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.at ["meta", "type"] D.string)
        (D.at ["meta", "slug"] D.string)
        (D.at ["meta", "first_published_at"] dateDecoder)
        (D.at ["meta", "seo_title"] D.string)


type alias HomePageContent =
    { meta : WagtailMetaContent
    , theme : Theme
    , cover :
        { text : String
        , link : String
        }
    , cases : List CasePreview
    }


homePageDecoder : D.Decoder Page
homePageDecoder =
    D.map HomePage <|
        D.map4 HomePageContent
            metaDecoder
            decodeTheme
            (D.map2
                (\text link -> { text = text, link = link })
                (D.field "text" D.string)
                (D.field "link" D.string)
            )
            (D.field "value" decodeCasePreview
                |> D.list
                |> D.field "cases"
            )


type alias CasePageContent =
    { meta : WagtailMetaContent
    , theme : Theme
    , info :
        { caption : String
        , releaseDate : String
        , websiteUrl : String
        , relatedCase : CasePreview
        }
    , intro : Maybe String
    , body : Maybe (List Block)
    , image : Maybe Image
    , backgroundImage : Maybe Image
    }


casePageDecoder : D.Decoder Page
casePageDecoder =
    D.map CasePage <|
        D.map7 CasePageContent
            metaDecoder
            decodeTheme
            (D.map4
                (\x y z j ->
                    { caption = x
                    , releaseDate = y
                    , websiteUrl = z
                    , relatedCase = j
                    }
                )
                (D.field "caption" D.string)
                (D.field "release_date" D.string)
                (D.field "website_url" D.string)
                (D.field "related_case" decodeCasePreview)
            )
            (D.maybe <| D.field "intro" D.string)
            (D.maybe <| D.field "body" decodeBlocks)
            (D.maybe <| D.field "image_src" decodeImage)
            (D.maybe <| D.field "background_image_src" decodeImage)


type alias CasePreview =
    { theme : Theme
    , title : String
    , caption : String
    , url : String
    , backgroundImage : Maybe Image
    }


decodeCasePreview : D.Decoder CasePreview
decodeCasePreview =
    D.map5
        CasePreview
        decodeTheme
        (D.field "title" D.string)
        (D.field "caption" D.string)
        (D.field "url" D.string)
        (D.maybe <| D.field "background_image_src" decodeImage)


type alias Image =
    { image : String
    , caption : Maybe String
    }


decodeImage : D.Decoder Image
decodeImage =
    D.map2 Image
        (D.field "url" D.string)
        (D.maybe <| D.field "caption" D.string)



type alias Quote =
    { text : String
    , name : Maybe String
    }

decodeQuote : D.Decoder Block
decodeQuote =
    D.map QuoteBlock <|
        D.map2 Quote
            (D.field "text" D.string)
            (D.maybe <| D.field "name" D.string)


type alias Column =
    { theme : Theme
    , image : Maybe Image
    , richText : Maybe String
    }


decodeColumns : D.Decoder Block
decodeColumns =
    D.map2 ColumnBlock
        (D.field "left" decodeColumn)
        (D.field "right" decodeColumn)


decodeColumn : D.Decoder Column
decodeColumn =
    D.map3 Column
        decodeTheme
        (D.maybe <| D.field "image" decodeImage)
        (D.maybe <| D.field "rich_text" D.string)


type alias Theme =
    { backgroundColor : String
    , textColor : String
    , backgroundPosition : Maybe ( String, String )
    }


decodeTheme : D.Decoder Theme
decodeTheme =
    D.map3 Theme
        (D.field "background_color" D.string)
        (D.oneOf
            [ D.field "text_color" D.string
            , D.succeed "fff"
            ]
        )
        (D.maybe <|
            D.map2 (,)
                (D.oneOf
                    [ D.field "background_position_x" D.string
                    , D.field "position" D.string
                    ]
                )
                (D.oneOf
                    [ D.field "background_position_y" D.string
                    , D.succeed "center"
                    ]
                )
        )


type Block
    = UnknownBlock String
    | QuoteBlock Quote
    | ImageBlock Theme Image
    | ContentBlock Theme String
    | BackgroundBlock Image
    | ColumnBlock Column Column


decodeBlocks : D.Decoder (List Block)
decodeBlocks =
    D.field "type" D.string
        |> D.andThen
            (\blockType ->
                case blockType of
                    "quote" ->
                        D.field "value" decodeQuote

                    "image" ->
                        D.field "value" decodeImageBlock

                    "background" ->
                        D.field "value" decodeBackgroundBlock

                    "content" ->
                        D.field "value" decodeContentBlock

                    "columns" ->
                        D.field "value" decodeColumns

                    _ ->
                        D.succeed (UnknownBlock blockType)

            )
        |> D.list


decodeImageBlock : D.Decoder Block
decodeImageBlock =
    D.map2
        ImageBlock
        decodeTheme
        (D.field "image" decodeImage)


decodeBackgroundBlock : D.Decoder Block
decodeBackgroundBlock =
    D.map BackgroundBlock
        (D.field "image" decodeImage)


decodeContentBlock : D.Decoder Block
decodeContentBlock =
    D.map2
        ContentBlock
        decodeTheme
        (D.field "rich_text" D.string)


-- type alias CaseContent =
--     { meta :
--         { id : Int
--         , title : String
--         , caption : String
--         , releaseDate : String
--         , websiteUrl : String
--         }
--     , intro : Maybe String
--     , body : Maybe (List Block)
--     , image : Maybe Image
--     , backgroundImage : Maybe Image
--     , theme : Theme
--     }
-- 
-- 
-- 
-- type CaseState
--     = Cover
--     | Preview
--     | Open
-- 
-- 
-- type alias HomeContent =
--     { pageType : String
--     , cases : List CaseContent
--     , animation : Maybe String
--     , cover :
--         { text : String
--         , link : String
--         }
--     , theme : Theme
--     , easterEggImages : List (String, Image)
--     }
-- 
-- 
-- type alias ServicesContent =
--     { pageType : String
--     , caption : String
--     , body :
--         List
--             { title : String
--             , body : String
--             , services :
--                 List
--                     { text : String
--                     , service : Service
--                     }
--             }
--     }
-- 
-- 
-- type alias Service =
--     { title : String
--     , body : String
--     , slides : List Image
--     }
-- 
-- 
-- type alias Person =
--     { firstName : String
--     , lastName : String
--     , jobTitle : String
--     , photo : Image
--     , email : Maybe String
--     , phone : Maybe String
--     }
-- 
-- 
-- type alias CultureContent =
--     { pageType : String
--     , people : List Person
--     , cases : List CaseContent
--     , nextEvent : Maybe Event
--     , ideas : Maybe (List String)
--     }
-- 
-- 
-- type alias Event =
--     { date : String
--     , title : String
--     , image : Maybe Image
--     }
-- 


