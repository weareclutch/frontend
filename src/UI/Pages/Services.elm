module UI.Pages.Services exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, id)
import Html.Styled.Events exposing (onClick)
import Icons.Arrow exposing (arrow)
import Style exposing (..)
import Types exposing (..)
import UI.Common exposing (backgroundImg, container, siteMargins, slideshow)
import UI.Components.Blocks exposing (richText)
import Wagtail


view : Bool -> Wagtail.ServicesContent -> Html Msg
view isMobile content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                , padding4 (px 130) zero zero zero
                , bpMediumUp
                    [ padding4 (pct 20) zero zero zero
                    ]
                ]

        slideshowWrapper =
            styled div
                [ position relative
                , zIndex (int 1)
                ]

        title =
            styled h1
                [ color (hex "001AE0")
                ]

        contentWrapper =
            styled div
                [ maxWidth (px 820)
                ]
    in
    wrapper []
        [ container []
            [ siteMargins []
                [ contentWrapper []
                    [ title [] [ text content.title ]
                    , p [ class "intro" ] [ text content.introduction ]
                    ]
                ]
            ]
        , slideshowWrapper []
            [ slideshow
                "services-slideshow"
                ( 1, 1, 1 )
                slideImage
                content.images
            ]
        , servicesBlock isMobile content.services
        , expertisesBlock content.expertises
        ]


slideImage : Wagtail.Image -> Html msg
slideImage image =
    let
        wrapper =
            styled div
                [ backgroundSize cover
                , backgroundPosition center
                , height (px 300)
                , width (pct 100)
                , bpMediumUp
                    [ paddingTop (pct 40)
                    , height zero
                    ]
                ]
    in
    wrapper [ backgroundImg image ] []


servicesBlock : Bool -> ( Int, List Wagtail.Service ) -> Html Msg
servicesBlock isMobile ( activeIndex, services ) =
    let
        wrapper =
            styled div
                [ position relative
                , overflow hidden
                , zIndex (int 0)
                , width (pct 100)
                , backgroundColor (hex "222328")
                , color (hex "fff")
                , marginTop (px -60)
                , bpLargeUp
                    [ marginTop (px -190)
                    ]
                ]

        innerWrapper =
            styled div
                [ displayFlex
                ]

        navigation =
            styled div
                [ display none
                , backgroundColor (hex "292A32")
                , bpLargeUp
                    [ display inlineBlock
                    , position relative
                    , width (pct 34)
                    , verticalAlign top
                    , padding4 (px 360) zero (px 170) zero
                    ]
                , bpXLargeUp
                    [ padding4 (px 460) zero (px 270) zero
                    ]
                , before
                    [ property "content" "''"
                    , display block
                    , position absolute
                    , right zero
                    , top zero
                    , backgroundColor (hex "292A32")
                    , width (vw 100)
                    , height (pct 100)
                    , zIndex (int 0)
                    ]
                ]

        title =
            styled h2
                [ zIndex (int 1)
                , position relative
                ]

        contentWrapper =
            styled div
                [ width (pct 100)
                , bpLargeUp
                    [ width (pct 66) ]
                ]

        contentTitle =
            styled h2
                [ zIndex (int 1)
                , marginTop (px 140)
                , fontWeight (int 700)
                , bpLargeUp
                    [ display none
                    ]
                ]

        content =
            styled div
                [ display block
                , padding4 (px 10) zero (px 40) zero
                , bpLargeUp
                    [ display inlineBlock
                    , width (pct 100)
                    , verticalAlign top
                    , padding4 (px 360) zero (px 170) zero
                    , maxWidth (px 980)
                    ]
                , bpXLargeUp
                    [ padding4 (px 460) zero (px 270) (px 180)
                    ]
                ]

        serviceWrapper =
            \active ->
                styled div
                    [ display block
                    , width <| calc (pct 100) plus (px 160)
                    , marginLeft (px -80)
                    , borderBottom3 (px 1) solid (hex "000")
                    , lastChild
                        [ borderBottom3 (px 1) solid transparent
                        ]
                    , bpLargeUp
                        [ borderBottom3 (px 1) solid transparent
                        , width (pct 100)
                        , marginLeft zero
                        , if active then
                            display block

                          else
                            display none
                        ]
                    ]

        serviceTitle =
            styled p
                [ display block
                , cursor pointer
                , paddingLeft (px 80)
                , margin2 (px 36) zero
                , position relative
                , bpLargeUp
                    [ display none
                    ]
                ]

        arrowWrapper =
            styled div
                [ display inlineBlock
                , position absolute
                , right (px 80)
                , margin2 auto zero
                , transform (rotate (deg 90))
                , bpLargeUp
                    [ display none
                    ]
                ]

        collapsableBlock =
            \active ->
                styled div <|
                    [ padding2 zero (px 80)
                    , if active then
                        display block

                      else
                        display none
                    , bpLargeUp
                        [ display block ]
                    ]

        navigationItems =
            styled ul
                [ listStyle none
                , padding zero
                ]

        navigationItem =
            \active ->
                styled li
                    [ margin zero
                    , padding2 (px 26) zero
                    , fontSize (px 22)
                    , lineHeight (px 22)
                    , letterSpacing (px 2)
                    , fontFamilies [ "Qanelas ExtraBold" ]
                    , fontWeight (int 400)
                    , cursor pointer
                    , if active then
                        backgroundColor <| hex "001AE0"

                      else
                        backgroundColor transparent
                    , position relative
                    , hover
                        [ backgroundColor (hex "001AE0")
                        ]
                    , before
                        [ property "content" "''"
                        , display block
                        , backgroundColor inherit
                        , position absolute
                        , top zero
                        , left (px -40)
                        , width (px 40)
                        , height (pct 100)
                        ]
                    ]
    in
    wrapper []
        [ container []
            [ siteMargins []
                [ innerWrapper []
                    [ navigation []
                        [ title [] [ text "Wat we doen" ]
                        , navigationItems [] <|
                            List.indexedMap
                                (\index service ->
                                    navigationItem
                                        (index == activeIndex || index == 0 && activeIndex == -1)
                                        [ onClick <|
                                            WagtailMsg <|
                                                Wagtail.UpdateServicesState index
                                        ]
                                        [ text service.title ]
                                )
                                services
                        ]
                    , contentWrapper []
                        [ contentTitle [] [ text "Wat we doen" ]
                        , content [] <|
                            List.indexedMap
                                (\index service ->
                                    let
                                        active =
                                            index == activeIndex || index == 0 && activeIndex == -1

                                        activeMobile =
                                            index == activeIndex
                                    in
                                    serviceWrapper
                                        active
                                        []
                                        [ serviceTitle
                                            [ class "nav"
                                            , onClick <|
                                                WagtailMsg <|
                                                    Wagtail.UpdateServicesState <|
                                                        if activeMobile then
                                                            -1

                                                        else
                                                            index
                                            ]
                                            [ text service.title, arrowWrapper [] [ arrow "ffffff" ] ]
                                        , collapsableBlock activeMobile
                                            []
                                            [ richText service.body ]
                                        ]
                                )
                                services
                        ]
                    ]
                ]
            ]
        ]


expertisesBlock : List Wagtail.Expertise -> Html Msg
expertisesBlock expertises =
    let
        title =
            styled h2
                [ color (hex "001AE0")
                , maxWidth (px 525)
                , zIndex (int 1)
                , position relative
                ]

        paragraph =
            styled p
                [ zIndex (int 1)
                , position relative
                ]

        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , position relative
                , padding2 (px 50) zero
                , bpLargeUp
                    [ property "display" "flex"
                    , flexDirection row
                    , alignItems stretch
                    , padding zero
                    ]
                ]

        intro =
            styled div
                [ display block
                , width (pct 100)
                , bpLargeUp
                    [ padding2 (px 170) zero
                    , position relative
                    , backgroundColor (hex "F4F4F4")
                    , verticalAlign top
                    , width (pct 34)
                    , paddingRight (px 60)
                    , display inlineBlock
                    ]
                , bpXLargeUp
                    [ padding2 (px 270) zero
                    ]
                , before
                    [ property "content" "''"
                    , position absolute
                    , right zero
                    , top zero
                    , backgroundColor (hex "F4F4F4")
                    , width (vw 100)
                    , height (pct 100)
                    , zIndex (int 0)
                    , display none
                    , bpLargeUp
                        [ display block
                        ]
                    ]
                ]

        content =
            styled div
                [ display block
                , width (pct 100)
                , bpLargeUp
                    [ padding4 (px 170) zero (px 170) (px 90)
                    , width (pct 64)
                    , display inlineBlock
                    , verticalAlign top
                    ]
                , bpXLargeUp
                    [ padding4 (px 270) zero (px 270) (px 180)
                    ]
                ]
    in
    container []
        [ siteMargins []
            [ wrapper []
                [ intro []
                    [ title [] [ text "Hoe we het doen" ]
                    , paragraph [ class "intro" ] [ p [] [richText "Goed doordachte idee&euml;n vormen de basis, maar met liefde in de executie maak je het verschil."] ]
                    ]
                , content [] <|
                    List.indexedMap
                        renderExpertise
                        expertises
                ]
            ]
        ]


renderExpertise : Int -> Wagtail.Expertise -> Html Msg
renderExpertise index expertise =
    let
        wrapper =
            styled div
                [ borderBottom3 (px 1) solid (hex "E4E4E4")
                , lastChild
                    [ borderBottomWidth zero
                    ]
                ]

        header =
            styled div
                [ padding2 (px 50) zero

                -- , cursor pointer
                , position relative
                , bpLargeUp
                    -- [ padding4 (px 60) zero (px 60) (px 180)
                    [ padding2 (px 60) zero
                    ]
                ]

        animationWrapper =
            styled div
                [ width (px 180)
                , height (px 180)
                , position absolute
                , left (px -40)
                , top (pct 50)
                , transform <| translateY (pct -50)
                , display none

                -- , bpLargeUp
                --     [ display block
                --     ]
                ]

        title =
            \active ->
                styled h4
                    [ marginBottom (px 10)
                    , if active then
                        color <| hex "001AE0"

                      else
                        color inherit
                    ]

        keywords =
            \active ->
                styled p
                    [ margin zero
                    , opacity <|
                        if active then
                            int 0

                        else
                            int 1
                    , height (px 32)
                    ]

        body =
            \active ->
                styled div
                    [ if active then
                        display block

                      else
                        display none
                    , marginTop (px -80)

                    -- , bpLargeUp
                    --     [ paddingLeft (px 180)
                    --     ]
                    ]
    in
    wrapper []
        [ header []
            -- [ onClick <| WagtailMsg <| Wagtail.UpdateExpertisesState index ]
            [ animationWrapper [ id <| "expertise-animation-" ++ String.fromInt index ] []
            , title expertise.active [] [ text expertise.title ]
            , keywords expertise.active
                []
                [ strong [] <|
                    List.map
                        (\keyword ->
                            text <|
                                String.trim keyword
                                    ++ ", "
                        )
                        expertise.keywords
                ]
            ]
        , body expertise.active
            []
            [ richText expertise.body
            ]
        ]
