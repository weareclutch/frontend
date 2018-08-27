module UI.State exposing (..)

import Json.Decode as D
import Wagtail exposing (siteUrl, Page, getPageId)
import Http


type NavigationState
    = Closed
    | Open Int
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


addPageToNavigationTree : Page -> NavigationTree -> NavigationTree
addPageToNavigationTree page { title, items } =
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


isNavigationPage : NavigationTree -> Page -> Bool
isNavigationPage nav page =
    nav.items
        |> List.any
            (\item ->
                item.id == (getPageId page)
            )




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


