module UI.State exposing (ContactInformation, Msg(..), NavigationItem, NavigationState(..), NavigationTree, OverlayPart, OverlayState, addPageToNavigationTree, addPageToOverlayState, closeOverlay, decodeContactInformation, decodeNavigation, fetchContactInformation, fetchNavigation, isNavigationPage, setNavigationPageActive)

import Http
import Json.Decode as D
import Wagtail exposing (Page, Theme, decodeTheme, getPageId, siteUrl)


type NavigationState
    = Closed
    | Open Int
    | OpenContact


type Msg
    = FetchNavigation (Result Http.Error NavigationTree)
    | ChangeNavigation NavigationState
    | FetchContactInformation (Result Http.Error ContactInformation)


type alias NavigationItem =
    { id : Int
    , title : String
    , path : String
    , page : Maybe Page
    , active : Bool
    }


type alias NavigationTree =
    { items : List NavigationItem
    }


type alias OverlayState =
    { active : Bool
    , parts : ( Maybe OverlayPart, Maybe OverlayPart )
    }


type alias OverlayPart =
    { page : Wagtail.Page
    , active : Bool
    }


type alias ContactInformation =
    { title : String
    , phone : String
    , email : String
    , address : String
    }


closeOverlay : OverlayState -> OverlayState
closeOverlay state =
    { active = False
    , parts =
        case state.parts of
            ( Just a, Nothing ) ->
                ( Just { page = a.page, active = False }
                , Nothing
                )

            ( Just a, Just b ) ->
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
            ( Nothing, Nothing ) ->
                ( Just { page = page, active = True }
                , Nothing
                )

            ( Just a, Nothing ) ->
                ( Just { page = a.page, active = False }
                , Just { page = page, active = True }
                )

            ( Just a, Just b ) ->
                if a.active && not b.active then
                    ( Just { page = a.page, active = False }
                    , Just { page = page, active = True }
                    )

                else
                    ( Just { page = page, active = True }
                    , Just { page = b.page, active = False }
                    )

            _ ->
                state.parts
    }


addPageToNavigationTree : Page -> NavigationTree -> NavigationTree
addPageToNavigationTree page { items } =
    { items =
        items
            |> List.map
                (\item ->
                    if item.id == getPageId page then
                        { item | page = Just page }

                    else
                        item
                )
    }


setNavigationPageActive : Page -> NavigationTree -> NavigationTree
setNavigationPageActive page nav =
    if isNavigationPage nav page then
        { items =
            nav.items
                |> List.map
                    (\item ->
                        if item.id == getPageId page then
                            { item | active = True }

                        else
                            { item | active = False }
                    )
        }

    else
        nav


isNavigationPage : NavigationTree -> Page -> Bool
isNavigationPage nav page =
    nav.items
        |> List.any
            (\item ->
                item.id == getPageId page
            )


fetchNavigation : String -> Cmd Msg
fetchNavigation siteIdentifier =
    Http.send FetchNavigation <|
        Http.get (siteUrl ++ "/api/navigation/" ++ siteIdentifier ++ "/") decodeNavigation


fetchContactInformation : String -> Cmd Msg
fetchContactInformation siteIdentifier =
    Http.send FetchContactInformation <|
        Http.get (siteUrl ++ "/api/contact/" ++ siteIdentifier ++ "/") decodeContactInformation


decodeNavigation : D.Decoder NavigationTree
decodeNavigation =
    D.map NavigationTree
        (D.field "items" <|
            D.list <|
                D.map5 NavigationItem
                    (D.field "id" D.int)
                    (D.field "title" D.string)
                    (D.field "slug" D.string)
                    (D.succeed Nothing)
                    (D.succeed False)
        )


decodeContactInformation : D.Decoder ContactInformation
decodeContactInformation =
    D.map4 ContactInformation
        (D.field "title" D.string)
        (D.field "phone" D.string)
        (D.field "email" D.string)
        (D.field "address" D.string)
