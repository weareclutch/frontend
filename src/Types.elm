module Types exposing (..)

import Navigation exposing (Location)
import Http
import Dict exposing (Dict)


type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | OpenPage (Result Http.Error Page)
    | OpenCase (Result Http.Error Page)
    | SetCasePosition ( Float, Float )
    | ToggleMenu


type alias Model =
    { route : Route
    , pages : Dict String Page
    , activePage : Maybe Page
    , cases : Dict Int Page
    , activeCase : Maybe Page
    , casePosition : ( Float, Float )
    , menuActive : Bool
    }


type Route
    = HomeRoute
    | ServicesRoute
    | CultureRoute
    | ContactRoute
    | CaseRoute Int String
    | NotFoundRoute



type Page
    = Home HomeContent
    | Services ServicesContent
    | Culture ServicesContent
    | Contact ServicesContent
    | Case Int CaseContent



type alias HomeContent =
    { cases : List Page
    }


type alias CaseContent =
    { caption : String
    , releaseDate : String
    , websiteUrl : String
    , body : Maybe (List Block)
    }


type alias ServicesContent =
    { caption : String
    }


type Block
    = RichTextBlock String
    | QuoteBlock Quote


type alias Quote =
    { text : String
    , name : Maybe String
    }

