module UI.Pages.Contact exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import UI.Blocks exposing (richText)
import UI.Common exposing (image)


view : ContactContent -> Html msg
view content =
    div []
        [ text content.caption
        , richText content.intro
        , div [] <| List.map contactPerson content.contactPeople
        ]


contactPerson : Person -> Html msg
contactPerson person =
    div []
        [ text <| person.firstName ++ person.lastName
        , image person.photo
        ]
