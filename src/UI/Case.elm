module UI.Case exposing (staticView, overlay)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (styled, class)
import UI.Common exposing (addLink, loremIpsum, backgroundImg)
import UI.Blocks
import Dict


outerWrapper : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
outerWrapper active =
    let
        extraStyle =
            if active then
                []
            else
                [ zIndex (int 0)
                ]
    in
        styled div <|
            [ zIndex (int 80)
            , position absolute
            , top zero
            , left zero
            , width (vw 100)
            , height (vh 100)
            ]
                ++ extraStyle


overlayWrapper : Bool -> ( Float, Float ) -> List (Attribute msg) -> List (Html msg) -> Html msg
overlayWrapper active ( x, y ) =
    let
        extraStyle =
            if active then
                [ overflowY scroll
                , width (vw 100)
                , height (vh 100)
                , zIndex (int 10)
                , transforms
                    [ translate3d
                        (px -x)
                        (px -y)
                        zero
                    , translateZ zero
                    ]
                , property "transition" "all 0.28s ease-in"
                ]
            else
                [ overflowY hidden
                ]
    in
        styled div <|
            [ position relative
            , property "transition" "all 0.28s ease-out"
            , width (px 660)
            , height (px 940)
            , property "will-change" "width, height, transform"
            , transform <| translateZ zero
            , property "-webkit-overflow-scrolling" "touch"
            , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.5)
            , overflowX hidden
            , zIndex (int 5)
            , nthChild "even"
                [ margin4 (px 120) zero (px 120) (px 380)
                ]
            ]
                ++ extraStyle


staticView : Model -> Html Msg
staticView model =
    model.activeCase
        |> Maybe.andThen
            (\content ->
                case model.activePage of
                    Just _ ->
                        Nothing

                    Nothing ->
                        Just <|
                            outerWrapper True
                                []
                                [ overlay model [ content ] True
                                ]
            )
        |> Maybe.withDefault (outerWrapper False [] [])


overlay : Model -> List CaseContent -> Bool -> Html Msg
overlay model cases active =
    List.head cases
        |> Maybe.map
            (\content ->
                let
                    className =
                        class <| "overlay overlay-" ++ (toString content.id)

                    attributes =
                        if active then
                            [ className
                            ]
                        else
                            [ className
                            ]
                                ++ (addLink <| "/" ++ (toString content.id) ++ "/lorem")

                    caseViews =
                        if not active then
                            [ caseView content Cover ]
                        else
                            renderCases model cases
                in
                    overlayWrapper active
                        model.casePosition
                        attributes
                        caseViews
            )
        |> Maybe.withDefault (text "")


renderCases : Model -> List CaseContent -> List (Html Msg)
renderCases model cases =
    let
        activeIndex =
            model.activeCase
                |> Maybe.andThen
                    (\activeCase ->
                        cases
                            |> List.indexedMap (,)
                            |> List.filterMap
                                (\( index, content ) ->
                                    if content.id == activeCase.id then
                                        Just index
                                    else
                                        Nothing
                                )
                            |> List.head
                    )
                |> Maybe.withDefault 0
    in
        cases
            |> List.map
                (\content ->
                    model.cases
                        |> Dict.get content.id
                        |> Maybe.withDefault content
                )
            |> List.indexedMap (,)
            |> List.map
                (\( index, content ) ->
                    if index <= activeIndex then
                        caseView content Open
                    else if index == (activeIndex + 1) then
                        caseView content Preview
                    else
                        text ""
                )


caseView : CaseContent -> CaseState -> Html Msg
caseView content state =
    let
        wrapper =
            styled div <|
                [ position relative
                ]
    in
        case state of
            Open ->
                wrapper []
                    [ header state content
                    , body content
                    ]

            Cover ->
                wrapper []
                    [ header state content
                    ]

            Preview ->
                wrapper (addLink <| "/" ++ (toString content.id) ++ "/lorem")
                    [ header state content
                    ]


header : CaseState -> CaseContent -> Html msg
header state content =
    let
        backgroundStyle =
            content.theme.backgroundPosition
                |> Maybe.map
                    (\(x, y) ->
                        property "background-position" <| x ++ " " ++ y
                    )
                |> Maybe.withDefault
                        (property "background-position" "center")

        wrapper =
            styled div <|
                [ height <|
                    if state == Preview then
                        (pct 50)
                    else
                        (pct 100)
                , width (pct 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , backgroundStyle
                , property "transition" "all 0.28s ease-out"
                , position relative
                ]

        titleWrapper =
            styled h2 <|
                [ color (hex content.theme.textColor)
                , position absolute
                , bottom (px 20)
                , left (px 20)
                , fontSize (px 48)
                ]
    in
        wrapper
            [ backgroundImg content.image
            ]
            [ titleWrapper [] [ text content.title ]
            ]


body : CaseContent -> Html Msg
body content =
    let
        wrapper =
            styled div <|
                [ backgroundColor (hex "fff")
                , padding (px 80)
                ]

        blocks =
            content.body
                |> Maybe.andThen
                    (\body ->
                        Just <| UI.Blocks.streamfield body
                    )
                |> Maybe.withDefault (text "")
    in
        wrapper []
            [ blocks
            , p (addLink <| "/7/lorem") [ text "hello" ]
            ]
