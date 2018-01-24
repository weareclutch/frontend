module Types exposing (..)

import Navigation exposing (Location)
import Http
import Dict exposing (Dict)


type Msg
    = OnLocationChange Location
    | ChangeLocation String
    | OpenPage (Result Http.Error Page)
    | OpenCase (Result Http.Error Page)


type alias Model =
    { route : Route
    , pages : Dict String Page
    , activePage : PageType
    , cases : Dict Int Page
    , activeCase : Maybe Int
    }


type Route
    = HomeRoute
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
    | Case


type ContentType
    = HomePage HomeContent
    | CasePage CaseContent


type alias HomeContent =
    { cases : List String
    }


type alias CaseContent =
    { caption : String
    , releaseDate : String
    , websiteUrl : String
    }
