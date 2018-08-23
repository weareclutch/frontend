module Types exposing (..)

import Http
import Dict exposing (Dict)
import Navigation exposing (Location)

import Wagtail
import UI.State

type Msg
    = OnLocationChange Location
    | ChangeLocation String
    -- | OpenPage (Result Http.Error Page)
    -- | OpenCase (Result Http.Error CaseContent)
    -- | SetCasePosition ( Float, Float )
    -- | RepositionCase ( Float, Float )
    -- | OpenService Service
    -- | CloseService
    | NavigationMsg UI.State.Msg
    -- | SetParallaxPositions (List ( String, Float ))
    -- | ScrollEvent String Float
    -- | SetWindowDimensions (Float, Float)
    -- | SpinEasterEgg Float Float
    | WagtailMsg Wagtail.Msg


type alias Model =
    { route : Route
    -- , pages : Dict String Page
    -- , activePage : Maybe String
    -- , cases : Dict Int CaseContent
    -- , activeCase : Maybe CaseContent
    -- , activeOverlay : Maybe Int
    -- , activeService : Maybe Service
    -- , casePosition : ( Float, Float )
    , navigationTree : Maybe UI.State.NavigationTree
    , menuState : UI.State.MenuState
    -- , pageScrollPositions : Dict String Float
    -- , parallaxPositions : Dict String Float
    -- , windowDimensions : (Float, Float)
    }


type Route
    = UndefinedRoute
    | WagtailRoute Wagtail.Page
    | NotFoundRoute


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

