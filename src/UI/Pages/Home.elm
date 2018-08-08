module UI.Pages.Home exposing (view)

import Types exposing (..)
import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (class, attribute, id, href)
import UI.Case
import UI.Blocks exposing (richText)
import UI.Common exposing (button, parallax)
import Dict exposing (Dict)
import Style exposing (..)


view : Model -> HomeContent -> Html Msg
view model content =
    let
        pageScroll =
            model.pageScrollPositions
                |> Dict.get "home.HomePage"
                |> Maybe.withDefault 0

        (leftCases, rightCases) =
            content.cases
                |> List.indexedMap
                    (\index page ->
                        (index, UI.Common.link (toString page.meta.id ++ "/" ++ page.meta.title ) [text page.meta.title] )
                    )
                |> List.partition (\(idx, _) -> idx % 2 == 0)
                |> \(left, right) -> ( List.map Tuple.second left, List.map Tuple.second right)

        innerWrapper =
            styled div
                [ width (pct 100)
                , maxWidth (px 1400)
                , margin auto
                , position relative
                ]

        caseWrapper =
            styled div
                [ bpMedium
                    [ width <| calc (pct 50) minus (px 30)
                    ]
                , bpLarge
                    [ width <| calc (pct 50) minus (px 40)
                    ]
                , bpXLargeUp
                    [ width <| calc (pct 50) minus (px 60)
                    ]
                , nthChild "even"
                    [ bpMediumUp
                        [ position absolute
                        , top (px 350)
                        , right zero
                        ]
                    ]
                ]
    in
        div [ class "home" ] <|
            [ pageWrapper
                [ innerWrapper []
                    [ caseWrapper [] leftCases
                    , caseWrapper [] rightCases
                    ]
                ]
            , introCover pageScroll content
            , easterEgg
                model.parallaxPositions
                pageScroll
                (Tuple.second model.windowDimensions)
            ]


pageWrapper : List (Html Msg) -> Html Msg
pageWrapper children =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , position relative
                , zIndex (int 10)
                , backgroundColor (hex "292A32")
                , padding4 (px 140) (px 25) (px 80) (px 25)
                , bpMedium
                    [ padding4 (px 280) (px 80) (px 140) (px 80)
                    ]
                , bpLarge
                    [ padding4 (px 280) (px 140) (px 140) (px 140)
                    ]
                , bpXLargeUp
                    [ padding4 (px 280) (px 240) (px 140) (px 240)
                    ]
                ]

        innerWrapper =
            styled div
                [ margin auto
                , padding4 zero zero (px 280) zero
                ]
    in
        wrapper []
            [ innerWrapper [] children
            ]


introCover : Float -> HomeContent -> Html msg
introCover offset content =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , height (vh 100)
                , backgroundColor (hex content.theme.backgroundColor)
                , position relative
                , zIndex (int 5)
                ]

        title =
            styled div
                [ letterSpacing (px 2)
                , fontSize (px 22)
                , fontWeight (int 500)
                , marginBottom (px 6)
                ]

        textWrapper =
            styled div
                [ color (hex content.theme.textColor)
                , maxWidth (px 660)
                , margin auto
                , transform (translateY (pct -50))
                , top (pct 50)
                , left (pct 50)
                , position absolute
                ]

        lottiePlayer =
            styled div
                [ position relative
                , maxWidth (px 600)
                , maxHeight (px 600)
                , width (pct 100)
                , height (pct 100)
                , margin auto
                , top (pct 50)
                , transform <| translateY (pct -50)
                ]
    in
        wrapper []
            [ lottiePlayer
                [ attribute "data-anim-loop" "true"
                , attribute "data-animation-path" "animation/"
                , attribute "data-name" "loader"
                , id "home-animation"
                ]
                []
            , textWrapper [ ]
                [ title [] [ text "Uitgelicht" ]
                , richText content.cover.text
                , a [ href content.cover.link ]
                    [ UI.Common.button content.theme [] (Just "lees verder")
                    ]
                ]
            ]


easterEgg : Dict String Float -> Float -> Float -> Html msg
easterEgg dict offset windowHeight =
    let
        (size, displayText) =
            Dict.get "scroll" dict
                |> Maybe.map
                    (\pos ->
                        if offset > pos - windowHeight * 0.8 then
                            (48, "Wil je niet naar een hoger niveau?")
                        else if offset > pos - windowHeight * 1.2 then
                            (36, "Andere omhoog")
                        else
                            (22, "Scroll omhoog")
                    )
                |> Maybe.withDefault (22, "Scroll omhoog")

        wrapper =
            styled div
                [ height (vh 100)
                , width (vw 100)
                , backgroundColor (hex "292A32")
                , position relative
                ]

        titleWrapper =
            styled div
                [ top (vh 55)
                , width (pct 100)
                , position absolute
                ]

        title =
            styled h2
                [ fontSize (px size)
                , color (hex "fff")
                , textAlign center
                , letterSpacing (px 2)
                , transition "all" 0.16 0 "ease-in-out"
                ]
    in
        wrapper []
            [ titleWrapper
                (parallax dict offset "scroll")
                [ title [] [ text displayText ]
                ]
            ]
