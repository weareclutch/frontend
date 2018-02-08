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
    | OpenService Service
    | CloseService
    | CloseMenu
    | OpenMenu MenuState


type alias Model =
    { route : Route
    , pages : Dict String Page
    , activePage : Maybe String
    , cases : Dict Int CaseContent
    , activeCase : Maybe CaseContent
    , activeOverlay : Maybe Int
    , activeService : Maybe Service
    , casePosition : ( Float, Float )
    , menuState : MenuState
    }


type MenuState
    = Closed
    | OpenTop
    | OpenBottom


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
    | Culture CultureContent
    | Contact ContactContent
    | Case CaseContent


type alias CaseContent =
    { id : Int
    , title : String
    , caption : String
    , releaseDate : String
    , websiteUrl : String
    , body : Maybe (List Block)
    }


type CaseState
    = Cover
    | Preview
    | Open


type alias HomeContent =
    { pageType : String
    , cases : List CaseContent
    }


type alias ServicesContent =
    { pageType : String
    , caption : String
    , body :
        List
            { title : String
            , body : String
            , services :
                List
                    { text : String
                    , service : Service
                    }
            }
    }


type alias Service =
    { title : String
    , body : String
    , slides : List Image
    }


type alias ContactContent =
    { pageType : String
    , caption : String
    , intro : String
    , contactPeople : List Person
    }


type alias Person =
    { firstName : String
    , lastName : String
    , jobTitle : String
    , photo : Image
    , email : Maybe String
    , phone : Maybe String
    }


type alias CultureContent =
    { pageType : String
    , people : List Person
    , cases : List CaseContent
    , nextEvent : Maybe Event
    , ideas : Maybe (List String)
    }


type alias Event =
    { date : String
    , title : String
    , image : Maybe Image
    }


type Block
    = RichTextBlock String
    | QuoteBlock Quote


type alias Quote =
    { text : String
    , name : Maybe String
    }


type alias Image =
    { image : String
    , caption : Maybe String
    }
