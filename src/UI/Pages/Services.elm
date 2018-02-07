module UI.Pages.Services exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import UI.Common exposing (loremIpsum)


view : ServicesContent -> Html msg
view content =
    div [] <|
        [ text content.caption
        , renderBody content
        ]


renderBody : ServicesContent -> Html msg
renderBody content =
    content.body
        |> List.map
            (\{ title, body, services } ->
                div []
                    [ h1 [] [ text title ]
                    , p [] [ text body ]
                    , ul []
                        (services
                            |> List.map
                                (\service ->
                                    li [] [ text service.text ]
                                )
                        )
                    ]
            )
        |> div []
