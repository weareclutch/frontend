module UI.Pages.Services exposing (view, overlay)

import Types exposing (..)
import Html.Styled exposing (..)
import UI.Common exposing (loremIpsum)
import Html.Styled.Attributes exposing (styled)
import Css exposing (..)
import Html.Styled.Events exposing (onClick)
import UI.Common exposing (backgroundImg)


view : ServicesContent -> Html Msg
view content =
    div [] <|
        [ text content.caption
        , renderBody content
        ]


renderBody : ServicesContent -> Html Msg
renderBody content =
    content.body
        |> List.map
            (\{ title, body, services } ->
                let
                    serviceLinks =
                        services
                            |> List.map
                                (\service ->
                                    li
                                        [ onClick <| OpenService service.service
                                        ]
                                        [ text service.text
                                        ]
                                )
                in
                    div []
                        [ h1 [] [ text title ]
                        , p [] [ text body ]
                        , ul [] serviceLinks
                        ]
            )
        |> div []


overlay : Maybe Service -> Html Msg
overlay service =
    let
        outerWrapper =
            styled div
                [ position absolute
                , left zero
                , top zero
                , height (vh 100)
                , width (vw 100)
                , backgroundColor (rgba 0 0 0 0.2)
                , zIndex (int 200)
                ]

        wrapper =
            styled div
                [ position absolute
                , top (pct 50)
                , left (pct 50)
                , transform (translate2 (pct -50) (pct -50))
                , minHeight (px 300)
                , minWidth (px 300)
                , backgroundColor (hex "fff")
                , zIndex (int 200)
                ]

        slide =
            styled div
                [ width (px 320)
                , height (px 200)
                , display inlineBlock
                ]
    in
        service
            |> Maybe.map
                (\service ->
                    let
                        slides =
                            service.slides
                                |> List.map
                                    (\image ->
                                        slide [ backgroundImg image ] []
                                    )
                    in
                        outerWrapper []
                            [ wrapper []
                                [ h1 [] [ text service.title ]
                                , p [] [ text service.body ]
                                , div [] slides
                                , button [ onClick CloseService ] [ text "close" ]
                                ]
                            ]
                )
            |> Maybe.withDefault (text "")
