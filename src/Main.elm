module Main exposing (..)

import Types exposing (..)
import Navigation exposing (Location)
import Routing exposing (parseLocation, getCommand)
import Html.Styled exposing (..)
import Dict exposing (Dict)


initModel : Route -> Model
initModel route =
    { route = route
    , pages = Dict.empty
    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        route =
            parseLocation location

        command =
            getCommand route <| initModel NotFoundRoute
    in
        ( initModel route, command )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                newRoute =
                    parseLocation location

                command =
                    getCommand newRoute model
            in
                ( { model | route = newRoute }, command )

        ChangeLocation path ->
            ( model, Navigation.newUrl path )

        AddPage (Ok page) ->
            let
                pages =
                    Dict.insert page.id page model.pages
            in
                ( { model | pages = pages }, Cmd.none )

        AddPage (Err err) ->
            Debug.log (toString err) ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.route of
        HomeRoute ->
            div [] [ text "home" ]

        CaseRoute id title ->
            div [] [ text "case page" ]

        NotFoundRoute ->
            div [] [ text "404" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
