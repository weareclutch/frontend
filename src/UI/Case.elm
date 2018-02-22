module UI.Case exposing (staticView, overlay)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class)
import UI.Common exposing (addLink, loremIpsum, backgroundImg)
import UI.Blocks
import Dict
import Style exposing (..)


overlayZoom : { time : Float, delay : Float, transition : String }
overlayZoom =
    { time = 0.3
    , delay = 0
    , transition = "ease-in-out"
    }


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
                , left (px -x)
                , top (px -y)
                ]
            else
                [ overflowY hidden
                , height (px 540)
                , marginBottom (px 25)
                , bpMedium
                    [ height (px 540)
                    , marginBottom (px 60)
                    ]
                , bpLarge
                    [ height (px 680)
                    , marginBottom (px 80)
                    ]
                , bpXLargeUp
                    [ height (px 940)
                    , marginBottom (px 135)
                    ]
                ]
    in
        styled div <|
            [ position relative
            , transition "all" overlayZoom.time 0 overlayZoom.transition
            , left (px 0)
            , top (px 0)
            , width (pct 100)
            , property "will-change" "width, height, top, left"
            , transform <| translateZ zero
            , property "-webkit-overflow-scrolling" "touch"
            , boxShadow4 zero (px 20) (px 50) (rgba 0 0 0 0.5)
            , overflowX hidden
            , pseudoElement "-webkit-scrollbar"
                [ display none
                ]
            , property "-ms-overflow-style" "none"
            , zIndex (int 5)
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
                        class <| "overlay overlay-" ++ (toString content.meta.id)

                    attributes =
                        if active then
                            [ className
                            ]
                        else
                            [ className
                            ]
                                ++ (addLink <| "/" ++ (toString content.meta.id) ++ "/lorem")

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
                                    if content.meta.id == activeCase.meta.id then
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
                        |> Dict.get content.meta.id
                        |> Maybe.withDefault content
                )
            |> List.indexedMap
                (\index content ->
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
                wrapper (addLink <| "/" ++ (toString content.meta.id) ++ "/lorem")
                    [ header state content
                    ]


header : CaseState -> CaseContent -> Html msg
header state content =
    let
        wrapperAttributes =
            content.backgroundImage
                |> Maybe.map
                    (\image ->
                        [ backgroundImg image ]
                    )
                |> Maybe.withDefault []

        image =
            content.image
                |> Maybe.map (layerImage state content.theme)
                |> Maybe.withDefault (text "")

        wrapper =
            styled div <|
                [ height <|
                    if state == Preview then
                        (pct 50)
                    else
                        (pct 100)
                , width (pct 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , backgroundPosition center
                , transition "all" overlayZoom.time overlayZoom.delay overlayZoom.transition
                , position relative
                ]

        titleWrapper =
            styled h2
                [ color (hex content.theme.textColor)
                , position absolute
                , bottom (px 20)
                , left (px 20)
                , fontSize (px 48)
                ]
    in
        wrapper wrapperAttributes
            [ image
            , titleWrapper [] [ text content.meta.title ]
            ]


layerImage : CaseState -> Theme -> Image -> Html msg
layerImage state theme image =
    let
        size =
            case state of
                Open ->
                    [ width (px 900)
                    , height (px 900)
                    ]

                _ ->
                    [ width (px 500)
                    , height (px 500)
                    ]

        positionStyles =
            theme.backgroundPosition
                |> Maybe.map
                    (\( x, y ) ->
                        let
                            xStyle =
                                case x of
                                    "left" ->
                                        [ left <|
                                            if state == Open then
                                                (px -100)
                                            else
                                                (px -200)
                                        , position absolute
                                        ]

                                    "right" ->
                                        [ right <|
                                            if state == Open then
                                                (px -100)
                                            else
                                                (px -200)
                                        , position absolute
                                        ]

                                    _ ->
                                        [ margin auto
                                        , position relative
                                        ]

                            yStyle =
                                case y of
                                    "top" ->
                                        [ top zero ]

                                    "bottom" ->
                                        [ bottom zero ]

                                    _ ->
                                        [ transform <|
                                            translateY (pct -50)
                                        , top (pct 50)
                                        ]
                        in
                            xStyle ++ yStyle
                    )
                |> Maybe.withDefault
                    [ top zero
                    , left zero
                    ]

        wrapper =
            styled div <|
                [ transition "all" overlayZoom.time overlayZoom.delay overlayZoom.transition
                ]
                    ++ positionStyles
                    ++ size
    in
        wrapper [ backgroundImg image ] []


body : CaseContent -> Html Msg
body content =
    let
        wrapper =
            styled div <|
                [ position relative
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
            ]
