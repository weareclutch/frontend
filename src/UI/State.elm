module UI.State exposing (..)

import Json.Decode as D
import Wagtail exposing (siteUrl, Page, getPageId, Theme, decodeTheme)
import Http


type NavigationState
    = Closed
    | Open Int
    | OpenContact


type Msg
    = FetchNavigation (Result Http.Error NavigationTree)
    | ChangeNavigation NavigationState


type alias NavigationItem =
    { id : Int
    , title : String
    , path : String
    , page : Maybe Page
    , theme : Theme
    }


type alias NavigationTree =
    { title : String
    , items: List NavigationItem
    }


type alias OverlayState =
    { active : Bool
    , parts : (Maybe OverlayPart, Maybe OverlayPart)
    }


type alias OverlayPart =
    { page: Wagtail.Page
    , active : Bool
    }


closeOverlay : OverlayState -> OverlayState
closeOverlay state =
    { active = False
    , parts =
        case state.parts of
            (Just a, Nothing) ->
                ( Just { page = a.page, active = False }
                , Nothing
                )
            (Just a, Just b) ->
                ( Just { page = a.page, active = False }
                , Just { page = b.page, active = False }
                )
            _ ->
                state.parts
    }


addPageToOverlayState : OverlayState -> Page -> OverlayState
addPageToOverlayState state page =
    { active = True
    , parts =
        case state.parts of
            (Nothing, Nothing) ->
                ( Just { page = page, active = True }
                , Nothing 
                )

            (Just a, Nothing) ->
                ( Just { page = a.page, active = False }
                , Just { page = page, active = True }
                )

            (Just a, Just b) ->
                if a.active && not b.active then
                    ( Just { page = a.page, active = False }
                    , Just { page = page, active = True }
                    )
                else
                    ( Just { page = page, active = True }
                    , Just { page = b.page, active = False }
                    )

            _ -> state.parts

    }


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
            D.map5 NavigationItem
                (D.at ["page", "id"] D.int)
                (D.field "title" D.string)
                (D.at ["page", "path"] D.string)
                (D.succeed Nothing)
                (D.field "page" decodeTheme)
        )


