module UI.Pages.Culture exposing (view)

import Html.Styled exposing (..)
import Types exposing (..)
import UI.Common exposing (image, loremIpsum)


view : Model -> CultureContent -> Html Msg
view model content =
    let
        nextEvent =
            content.nextEvent
                |> Maybe.map event
                |> Maybe.withDefault (text "")

        cases =
            []

        -- content.cases
        --     |> List.indexedMap
        --         (\index page ->
        --             model.activeOverlay
        --                 |> Maybe.andThen (\id -> Just (id == page.meta.id))
        --                 |> Maybe.withDefault False
        --                 |> UI.Case.overlay model (List.drop index content.cases)
        --         )
    in
    div []
        [ div [] cases
        , div [] <| List.map person content.people
        , nextEvent
        ]


person : Person -> Html msg
person { firstName, photo, jobTitle } =
    div []
        [ h1 [] [ text firstName ]
        , h2 [] [ text jobTitle ]
        , image photo
        ]


event : Event -> Html msg
event data =
    let
        imageEl =
            data.image
                |> Maybe.map image
                |> Maybe.withDefault (text "")
    in
    div []
        [ h2 [] [ text data.title ]
        , h3 [] [ text data.date ]
        , imageEl
        ]
