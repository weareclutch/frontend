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
    , activePage : PageType
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


type alias Page =
    { id : Int
    , title : String
    , pageType : PageType
    , content : ContentType
    }


type PageType
    = Home
    | Services
    | Culture
    | Contact
    | Case


type ContentType
    = HomeContentType HomeContent
    | CaseContentType CaseContent
    | ServicesContentType ServicesContent


type alias HomeContent =
    { cases : List Page
    }


type alias CaseContent =
    { caption : String
    , releaseDate : String
    , websiteUrl : String
    }


type alias ServicesContent =
    { caption : String
    }
