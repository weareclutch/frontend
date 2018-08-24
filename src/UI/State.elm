module UI.State exposing (NavigationState(..), Msg(..), NavigationTree, NavigationItem, fetchNavigation, addPageToNavigationTree)

import Json.Decode as D
import Wagtail exposing (siteUrl, Page, getPageId)
import Http


type NavigationState
    = Closed
    | Open
    | OpenContact


type alias NavigationItem =
    { id : Int
    , title : String
    , path : String
    , page : Maybe Page
    }

type alias NavigationTree =
    { title : String
    , items: List NavigationItem
    }

type Msg
    = FetchNavigation (Result Http.Error NavigationTree)
    | ChangeNavigation NavigationState



addPageToNavigationTree : NavigationTree -> Page -> NavigationTree
addPageToNavigationTree { title, items } page =
    { title = title
    , items =
        items
            |> List.map
                (\item ->
                    if item.id == getPageId page then
                        { item | page = Just page }
                    else
                        item
                )
    }


fetchNavigation : Cmd Msg
fetchNavigation =
    Http.send FetchNavigation <|
        Http.get (siteUrl ++ "/api/navigation") decodeNavigation


decodeNavigation : D.Decoder NavigationTree
decodeNavigation =
    D.map2 NavigationTree
        (D.field "title" D.string)
        (D.field "structure" <| D.list <|
            D.map4 NavigationItem
                (D.at ["page", "id"] D.int)
                (D.field "title" D.string)
                (D.at ["page", "path"] D.string)
                (D.succeed Nothing)
        )

