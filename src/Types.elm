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
    | RepositionCase ( Float, Float )
    | OpenService Service
    | CloseService
    | OpenMenu MenuState
    | ToggleMenu
    | OpenContact
    | SetParallaxPositions (List ( String, Float ))
    | ScrollEvent String Float
    | SetWindowDimensions (Float, Float)


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
    , pageScrollPositions : Dict String Float
    , parallaxPositions : Dict String Float
    , windowDimensions : (Float, Float)
    }


type MenuState
    = Closed
    | OpenTop
    | OpenBottom
    | OpenTopContact
    | OpenBottomContact


type Route
    = HomeRoute
    | ServicesRoute
    | CultureRoute
    | CaseRoute Int String
    | NotFoundRoute


type Page
    = Home HomeContent
    | Services ServicesContent
    | Culture CultureContent
    | Case CaseContent


type alias CaseContent =
    { meta :
        { id : Int
        , title : String
        , caption : String
        , releaseDate : String
        , websiteUrl : String
        }
    , intro : Maybe String
    , body : Maybe (List Block)
    , image : Maybe Image
    , backgroundImage : Maybe Image
    , theme : Theme
    }


type CaseState
    = Cover
    | Preview
    | Open


type alias HomeContent =
    { pageType : String
    , cases : List CaseContent
    , animation : Maybe String
    , cover :
        { text : String
        , link : String
        }
    , theme : Theme
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
    = UnknownBlock String
    | QuoteBlock Quote
    | ImageBlock Theme Image
    | ContentBlock Theme String
    | BackgroundBlock Image
    | ColumnBlock Column Column


type alias Quote =
    { text : String
    , name : Maybe String
    }


type alias Column =
    { theme : Theme
    , image : Maybe Image
    , richText : Maybe String
    }


type alias Image =
    { image : String
    , caption : Maybe String
    }


type alias Theme =
    { backgroundColor : String
    , textColor : String
    , backgroundPosition : Maybe ( String, String )
    }
