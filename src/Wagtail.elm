module Wagtail exposing (..)

import Date exposing (Date)
import Http exposing (..)
import Json.Decode as D
import Navigation


siteUrl : String
siteUrl =
    "http://staging.weareclutch.nl"


apiUrl : String
apiUrl =
    siteUrl ++ "/api/v2"


type Msg
    = LoadPage (Result Http.Error ( Response String, Page ))
    | PreloadPage (Result Http.Error Page)
    | UpdateServicesState Int
    | UpdateExpertisesState Int


type Page
    = HomePage HomePageContent
    | CasePage CasePageContent
    | BlogOverviewPage BlogOverviewContent
    | BlogCollectionPage BlogCollectionContent
    | BlogPostPage BlogPostContent
    | ServicesPage ServicesContent
    | AboutUsPage AboutUsContent


getPageId : Page -> Int
getPageId page =
    case page of
        HomePage { meta } ->
            meta.id

        CasePage { meta } ->
            meta.id

        BlogOverviewPage { meta } ->
            meta.id

        BlogCollectionPage { meta } ->
            meta.id

        BlogPostPage { meta } ->
            meta.id

        ServicesPage { meta } ->
            meta.id

        AboutUsPage { meta } ->
            meta.id


getPageTheme : Page -> Theme
getPageTheme page =
    case page of
        HomePage { theme } ->
            theme

        CasePage { theme } ->
            theme

        _ ->
            { backgroundColor = "fff"
            , textColor = "292A32"
            , backgroundPosition = Nothing
            }


getWagtailPage : Navigation.Location -> Cmd Msg
getWagtailPage location =
    Http.request
        { method = "GET"
        , headers = [ header "Accept" "application/json" ]
        , url = apiUrl ++ "/pages/find/?html_path=" ++ location.pathname
        , body = Http.emptyBody
        , expect =
            expectStringResponse
                (\r ->
                    D.decodeString
                        (decodePageType
                            |> D.andThen getPageDecoder
                            |> D.map (\page -> ( r, page ))
                        )
                        r.body
                )
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send LoadPage


preloadWagtailPage : String -> Cmd Msg
preloadWagtailPage path =
    Http.request
        { method = "GET"
        , headers = [ header "Accept" "application/json" ]
        , url = apiUrl ++ "/pages/find/?html_path=" ++ path
        , body = Http.emptyBody
        , expect =
            expectJson
                (decodePageType
                    |> D.andThen getPageDecoder
                )
        , timeout = Nothing
        , withCredentials = False
        }
        |> Http.send PreloadPage


decodePageType : D.Decoder String
decodePageType =
    D.at [ "meta", "type" ] D.string


getPageDecoder : String -> D.Decoder Page
getPageDecoder pageType =
    case pageType of
        -- Register the page decoders here ( "page.Type" -> aDecoder ) --
        "home.HomePage" ->
            homePageDecoder

        "case.CasePage" ->
            casePageDecoder

        "blog.BlogOverviewPage" ->
            blogOverviewPageDecoder

        "blog.BlogSeriesPage" ->
            blogCollectionPageDecoder

        "blog.BlogPostPage" ->
            blogPostPageDecoder

        "service.ServicesPage" ->
            servicesPageDecoder

        "about_us.AboutUsPage" ->
            aboutUsPageDecoder

        -- Default handler forn unknown types (aka "we can't handle")  --
        _ ->
            D.fail ("Can't find decoder for \"" ++ pageType ++ "\" type")


dateDecoder : D.Decoder Date
dateDecoder =
    D.string
        |> D.andThen (\s -> D.succeed (Date.fromString s |> Result.withDefault (Date.fromTime 0)))


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
        (D.at [ "meta", "type" ] D.string)
        (D.at [ "meta", "slug" ] D.string)
        (D.at [ "meta", "first_published_at" ] dateDecoder)
        (D.at [ "meta", "seo_title" ] D.string)


type alias HomePageContent =
    { meta : WagtailMetaContent
    , theme : Theme
    , cover :
        { text : String
        , link : String
        , image : Maybe Image
        }
    , cases : List CasePreview
    }


homePageDecoder : D.Decoder Page
homePageDecoder =
    D.map HomePage <|
        D.map4 HomePageContent
            metaDecoder
            decodeTheme
            (D.map3
                (\text link image -> { text = text, link = link, image = image })
                (D.field "text" D.string)
                (D.field "link" D.string)
                (D.field "image_src" <| D.maybe decodeImage)
            )
            (D.field "value" decodeCasePreview
                |> D.list
                |> D.field "cases"
            )



type alias Topic =
    { title : String
    , description : String
    , color : String
    }


type alias Person =
    { firstName : String
    , lastName : String
    , jobTitle : String
    , image : Image
    }


type alias AboutUsContent =
    { meta : WagtailMetaContent
    , title : String
    , introduction : String
    , images : List Image
    , bodyText :
        { left : String
        , right : String
        }
    , topics : List Topic
    , team :
        { title : String
        , text : String
        , people : List Person
        }
    , clients :
        { title : String
        , text : String
        , clients : List Image
        }
    }


aboutUsPageDecoder : D.Decoder Page
aboutUsPageDecoder =
    D.map AboutUsPage
        <| D.map8 AboutUsContent
            metaDecoder
            (D.field "title" D.string)
            (D.field "introduction" D.string)
            (D.field "images" <| D.list <| D.field "image" decodeImage)
            (D.map2
                (\left right -> { left = left, right = right })
                (D.field "left_body_text" D.string)
                (D.field "right_body_text" D.string)
            )
            (D.field "topics"
                <| D.list
                <| D.map3 Topic
                    (D.field "title" D.string)
                    (D.field "description" D.string)
                    (D.field "color" D.string)
            )
            (D.map3
                (\title text people -> { title = title, text = text, people = people })
                (D.field "team_title" D.string)
                (D.field "team_intro" D.string)
                (D.field "people"
                    <| D.list
                    <| D.field "person"
                    <| D.map4 Person
                        (D.field "first_name" D.string)
                        (D.field "last_name" D.string)
                        (D.field "job_title" D.string)
                        (D.field "photo" decodeImage)
                )
            )
            (D.map3
                (\title text clients -> { title = title, text = text, clients = clients })
                (D.field "client_title" D.string)
                (D.field "client_intro" D.string)
                (D.field "clients"
                    <| D.list
                    <| D.field "value"
                    <| D.map2
                        Image
                        (D.at ["image", "url"] D.string)
                        (D.maybe <| D.field "alt" D.string)
                )
            )


type alias Service =
    { body : String
    , title : String
    }


type alias Expertise =
    { body : String
    , keywords : List String
    , title : String
    , animationName : String
    , active : Bool
    }


type alias ServicesContent =
    { meta : WagtailMetaContent
    , title : String
    , introduction : String
    , images : List Image
    , services : (Int, List Service)
    , expertises : List Expertise
    }


servicesPageDecoder : D.Decoder Page
servicesPageDecoder =
    D.map ServicesPage
        <| D.map6 ServicesContent
            metaDecoder
            (D.field "title" D.string)
            (D.field "introduction" D.string)
            (D.field "images" <| D.list <| D.field "image" decodeImage)
            (D.field "what_we_do"
                <| D.map (\list -> (0, list))
                <| D.list
                <| D.map2 Service
                    (D.field "body_text" D.string)
                    (D.field "title" D.string)
            )
            (D.field "services"
                <| D.list
                <| D.map5 Expertise
                    (D.field "description" D.string)
                    (D.field "keywords" <| D.list D.string)
                    (D.field "title" D.string)
                    (D.field "animation_name" D.string)
                    (D.succeed False)
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


type alias BlogPostSeries =
    { slug : String
    , title : String
    , seriesSize : Int
    , seriesIndex : Int
    }


type alias BlogPostPreview =
    { id : Int
    , slug : String
    , title : String
    , readingTime : Int
    , intro : String
    , series : Maybe BlogPostSeries
    , image : Image
    }


blogPostPreviewDecoder : D.Decoder BlogPostPreview
blogPostPreviewDecoder =
    D.map7 BlogPostPreview
        (D.field "id" D.int)
        (D.field "slug" D.string)
        (D.field "title" D.string)
        (D.field "reading_time" D.int)
        (D.field "intro" D.string)
        (D.field "series" <|
            D.maybe <|
                D.map4 BlogPostSeries
                    (D.field "slug" D.string)
                    (D.field "title" D.string)
                    (D.field "series_amount" D.int)
                    (D.field "series_index" D.int)
        )
        (D.field "main_image" decodeImage)


type alias BlogSeriesPreview =
    { slug : String
    , title : String
    , seriesSize : Int
    , intro : String
    , image : Image
    }


blogSeriesPreviewDecoder : D.Decoder BlogSeriesPreview
blogSeriesPreviewDecoder =
    D.map5 BlogSeriesPreview
        (D.field "slug" D.string)
        (D.field "title" D.string)
        (D.field "series_amount" D.int)
        (D.field "intro" D.string)
        (D.field "image" decodeImage)


type alias BlogOverviewContent =
    { meta : WagtailMetaContent
    , title : String
    , introduction : String
    , blogSeries : List BlogSeriesPreview
    , blogPosts : List BlogPostPreview
    }


blogOverviewPageDecoder : D.Decoder Page
blogOverviewPageDecoder =
    D.map BlogOverviewPage <|
        D.map5 BlogOverviewContent
            metaDecoder
            (D.field "title" D.string)
            (D.field "introduction" D.string)
            (D.field "blog_series" <| D.list blogSeriesPreviewDecoder)
            (D.field "blog_posts" <| D.list blogPostPreviewDecoder)


type alias BlogCollectionContent =
    { meta : WagtailMetaContent
    , title : String
    , intro : String
    , image : Image
    , blogPosts : List BlogPostPreview
    }


blogCollectionPageDecoder : D.Decoder Page
blogCollectionPageDecoder =
    D.map BlogCollectionPage <|
        D.map5 BlogCollectionContent
            metaDecoder
            (D.field "title" D.string)
            (D.field "intro" D.string)
            (D.field "main_image" decodeImage)
            (D.field "blog_posts" <| D.list blogPostPreviewDecoder)


type alias BlogPostContent =
    { meta : WagtailMetaContent
    , title : String
    , intro : String
    , readingTime : Int
    , image : Image
    , body : Maybe (List Block)
    }


blogPostPageDecoder : D.Decoder Page
blogPostPageDecoder =
    D.map BlogPostPage <|
        D.map6 BlogPostContent
            metaDecoder
            (D.field "title" D.string)
            (D.field "intro" D.string)
            (D.field "reading_time" D.int)
            (D.field "main_image" decodeImage)
            (D.maybe <| D.field "body" decodeBlocks)


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
    , backgroundImage : Maybe Image
    , richText : Maybe String
    }


decodeColumns : D.Decoder Block
decodeColumns =
    D.map2 ColumnBlock
        (D.field "left" decodeColumn)
        (D.field "right" decodeColumn)


decodeColumn : D.Decoder Column
decodeColumn =
    D.map4 Column
        decodeTheme
        (D.maybe <| D.field "image" decodeImage)
        (D.maybe <| D.field "background_image" decodeImage)
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



