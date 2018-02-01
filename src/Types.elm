module Types exposing (..)

import Navigation exposing (Location)
import Http
import Dict exposing (Dict)


type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | OpenPage (Result Http.Error Page)
    | OpenCase (Result Http.Error CaseContent)
    | SetCasePosition ( Float, Float )
    | ToggleMenu


type alias Model =
    { route : Route
    , pages : Dict String Page
    , activePage : Maybe Page
    , cases : Dict Int CaseContent
    , activeCase : Maybe CaseContent
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
    | Case CaseContent


type alias CaseContent =
    { id : Int
    , title : String
    , caption : String
    , releaseDate : String
    , websiteUrl : String
    , body : Maybe (List Block)
    }


type alias HomeContent =
    { pageType : String
    , cases : List CaseContent
    }


type alias ServicesContent =
    { pageType : String
    , caption : String
    }


type alias TypedPage a =
    { a | pageType : String }


type Block
    = RichTextBlock String
    | QuoteBlock Quote


type alias Quote =
    { text : String
    , name : Maybe String
    }
