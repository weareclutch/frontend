module UI.Page exposing (container)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled)
import UI.Pages.Home
import UI.Pages.Services
import UI.Pages.Culture
import UI.Pages.Contact
import Dict


containerWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
containerWrapper =
    styled div <|
        [ backgroundColor (hex "f5f5f5")
        , height (vh 100)
        , width (vw 100)
        , position absolute
        , top zero
        , left zero
        ]


pageOrder : List PageType
pageOrder =
    [ Services
    , Culture
    , Contact
    , Home
    ]


container : Model -> Html Msg
container model =
    let
        activeDepth =
            pageOrder
              |> List.indexedMap (,)
              |> List.filterMap
                  (\(index, pageType) ->
                      if pageType == model.activePage then
                          Just index
                      else
                          Nothing
                  )
              |> List.head
              |> Maybe.withDefault 0

        pages =
            pageOrder
              |> List.indexedMap (,)
              |> List.map 
                  (\(index, pageType) ->
                      let
                          depth =
                              if index <= activeDepth then
                                  index - activeDepth

                              else
                                  index - activeDepth - List.length pageOrder

                      in
                          pageView model depth pageType
                  )

    in
        containerWrapper [] pages


pageWrapper : Int -> Bool -> Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
pageWrapper depth locked menuActive =
    let
        lockStyle =
            if locked then
                overflow hidden
            else
                overflow auto

        opacityStyle =
            if depth > 0 then
                opacity (int 0)
            else
                opacity (int 1)

        transformStyle =
            if menuActive then
                [ transforms
                    [ translate2
                        (px 0)
                        (px <| toFloat <| 100 * depth + 200)
                    , scale <| 0.1 * (toFloat depth) + 0.94
                    ]
                ]
            else
                [ transforms [] ]

        extraStyles =
            lockStyle :: opacityStyle :: transformStyle ++ []
    in
        styled div <|
            [ backgroundColor (hex "fff")
            , boxShadow4 zero (px 10) (px 25) (rgba 0 0 0 0.1)
            , height (vh 100)
            , width (vw 100)
            , position absolute
            , top zero
            , left zero
            , zIndex (int <| 10 + depth)
            , property "transition" "all 0.28s ease-in-out"
            ]
                ++ extraStyles


pageView : Model -> Int -> PageType -> Html Msg
pageView model depth pageType =
    let
        locked =
            model.activeCase
                |> Maybe.map (\activeCase -> True)
                |> Maybe.withDefault False

        page =
            case pageType of
                Home ->
                    model.pages
                        |> Dict.get (toString Home)
                        |> UI.Pages.Home.view model

                Services ->
                    model.pages
                        |> Dict.get (toString Services)
                        |> UI.Pages.Services.view

                Culture ->
                    model.pages
                        |> Dict.get (toString Culture)
                        |> UI.Pages.Culture.view

                Contact ->
                    model.pages
                        |> Dict.get (toString Contact)
                        |> UI.Pages.Contact.view

                _ ->
                    text "unknown type"
    in
        pageWrapper depth locked model.menuActive [] [ page ]

