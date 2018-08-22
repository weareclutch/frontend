module Wagtail exposing (siteUrl, Page, Msg, getWagtailPage)

import Http exposing (..)
import Navigation
import Json.Decode as Decode
import Date exposing (Date)


siteUrl : String
siteUrl =
    "https://weareclutch.nl"


apiUrl : String
apiUrl =
    siteUrl ++ "/api/v2"


type Msg
    = LoadPage (Result Http.Error Page)


type alias WagtailMetaContent =
    { type_ : String
    , slug : String
    , published : Date
    , seoTitle : String
    }

type Page
    = HomePage HomePageContent


getWagtailPage : Navigation.Location -> Cmd Msg
getWagtailPage location =
    Http.request
        { method = "GET"
        , headers = [header "Accept" "application/json"]
        , url = apiUrl ++ "/pages/find/?html_path=" ++ location.pathname
        , body = Http.emptyBody
        , expect = expectJson (
            decodePageType
                |> Decode.andThen getPageDecoder
        )
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send LoadPage



decodePageType : Decode.Decoder String
decodePageType =
    Decode.at ["meta", "type"] Decode.string


getPageDecoder : String -> Decode.Decoder Page
getPageDecoder pageType =
  case pageType of
    -- Register the page decoders here ( "page.Type" -> aDecoder ) --
    "home.HomePage" -> homePageDecoder

    -- Default handler forn unknown types (aka "we can't handle")  --
    _ -> Decode.fail ("Can't find decoder for \"" ++ pageType ++ "\" type")


dateDecoder : Decode.Decoder Date
dateDecoder  =
    Decode.string
        |> Decode.andThen ( \s -> Decode.succeed (Date.fromString s |> Result.withDefault (Date.fromTime 0)))

metaDecoder =
    Decode.map4 WagtailMetaContent
      (Decode.field "type" Decode.string)
      (Decode.field "slug" Decode.string)
      (Decode.field "first_published_at" dateDecoder)
      (Decode.field "seo_title" Decode.string)



type alias HomePageContent =
    { meta : WagtailMetaContent
    , title : String
    }

homePageDecoder =
    Decode.map HomePage <|
        Decode.map2 HomePageContent
            metaDecoder
            (Decode.succeed "foo")


