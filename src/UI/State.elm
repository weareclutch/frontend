module UI.State exposing (MenuState(..), Msg(..), NavigationTree, NavigationItem, fetchNavigation)

import Json.Decode as Decode
import Wagtail exposing (siteUrl)
import Http

type MenuState
    = Closed
    | OpenTop
    | OpenBottom
    | OpenTopContact
    | OpenBottomContact


type alias NavigationItem =
    { title : String
    , path : String
    }

type alias NavigationTree =
    { title : String
    , items: List NavigationItem
    }

type Msg
    = FetchNavigation (Result Http.Error NavigationTree)
    | OpenMenu MenuState
    | ToggleMenu
    | OpenContact



fetchNavigation : Cmd Msg
fetchNavigation =
    Http.send FetchNavigation <|
        Http.get (siteUrl ++ "/api/navigation") decodeNavigation


decodeNavigation : Decode.Decoder NavigationTree
decodeNavigation =
    Decode.map2 NavigationTree
        (Decode.field "title" Decode.string)
        (Decode.field "structure" <| Decode.list <|
            Decode.map2 NavigationItem
                (Decode.field "title" Decode.string)
                (Decode.at ["page", "path"] Decode.string)
        )

