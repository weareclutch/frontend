module UI.Pages.Services exposing (view)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Attributes exposing (class)
import Types exposing (..)
import Style exposing (..)
import Wagtail
import UI.Common exposing (slideshow, backgroundImg, loremIpsum, siteMargins)
import UI.Components.Blocks exposing (richText)


view : Wagtail.ServicesContent -> Html Msg
view content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                , padding4 (pct 20) zero zero zero
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


    in
    wrapper []
        [ siteMargins []
            [ title [] [ text content.title ]
            , p [ class "intro" ] [ text content.introduction ]
            ]

        , slideshowWrapper []
            [ slideshow
                "services-slideshow"
                (1, 1, 1)
                slideImage
                content.images
            ]
        , servicesBlock content.services
        , expertisesBlock content.expertises
        ]


slideImage : Wagtail.Image -> Html msg
slideImage image =
    let
        wrapper =
            styled div
                [ paddingTop (pct 40)
                , width (pct 100)
                , backgroundSize cover
                , backgroundPosition center
                ]

    in
        wrapper [ backgroundImg image ] []




servicesBlock : (Int, List Wagtail.Service) -> Html Msg
servicesBlock (activeIndex, services) =
    let
        wrapper =
            styled div
                [ position relative
                , zIndex (int 0)
                , width (pct 100)
                , backgroundColor (hex "222328")
                , color (hex "fff")
                , bpLargeUp
                    [ marginTop (px -190)
                    ]
                ]


        navigation =
            styled div
                [ display block
                , backgroundColor (hex "292A32")
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
                , bpLargeUp
                    [ display inlineBlock
                    , position relative
                    , width (pct 34)
                    , verticalAlign top
                    , padding4 (px 460) zero (px 270) zero
                    ]
                ]

        title =
            styled h2
                [ zIndex (int 1)
                , position relative
                ]

        content =
            styled div
                [ display block
                , bpLargeUp
                    [ display inlineBlock
                    , width (pct 66)
                    , verticalAlign top
                    , padding4 (px 460) zero (px 270) (px 180)
                    , maxWidth (px 980)
                    ]
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
                    , if active then (backgroundColor <| hex "001AE0")
                      else (backgroundColor transparent)
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
            [ siteMargins []
                [ navigation []
                    [ title [] [ text "Wat we doen" ]
                    , navigationItems []
                        <| List.indexedMap
                            (\index service ->
                                navigationItem
                                    (index == activeIndex)
                                    [ onClick
                                        <| WagtailMsg
                                        <| Wagtail.UpdateServicesState index
                                    ]
                                    [ text service.title ]
                            )
                            services
                    ]
                , content []
                    [ services
                        |> List.drop activeIndex
                        |> List.head
                        |> Maybe.map
                            (\service ->
                                richText service.body
                            )
                        |> Maybe.withDefault (text "")
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
                ]

        intro =
            styled div
                [ padding2 (px 270) zero
                , position relative
                , verticalAlign top
                , width (pct 34)
                , paddingRight (px 60)
                , display inlineBlock
                , backgroundColor (hex "F4F4F4")
                , before
                    [ property "content" "''"
                    , display block
                    , position absolute
                    , right zero
                    , top zero
                    , backgroundColor (hex "F4F4F4")
                    , width (vw 100)
                    , height (pct 100)
                    , zIndex (int 0)
                    ]
                ]

        content =
            styled div
                [ padding2 (px 270) zero
                , width (pct 64)
                , display inlineBlock
                , verticalAlign top
                , paddingLeft (px 180)
                ]

    in
        wrapper []
            [ siteMargins []
                [ intro []
                    [ title [] [ text "Hoe we het doen" ]
                    , paragraph [ class "intro" ] [ text "Donec facilisis prototyping ut augue lacinia, at viverra est semper. Sed sapien metus, scelerisque nec pharetra id, wireframing a tortor." ]
                    ]
                , content []
                    <| List.indexedMap
                        renderExpertise
                        expertises
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
                [ padding2 (px 60) zero
                , cursor pointer
                , position relative
                ]

        title =
            \active ->
                styled h4
                    [ marginBottom (px 10)
                    , if active then (color <| hex "001AE0") else (color inherit)
                    ]

        keywords =
            \active ->
                styled p
                    [ margin zero
                    , opacity <| if active then (int 0) else (int 1)
                    ]

        body =
            \active ->
                styled div
                    [ if active then (display block) else (display none)
                    ]

    in
        wrapper []
            [ header [ onClick <| WagtailMsg <| Wagtail.UpdateExpertisesState index ]
                [ title expertise.active [] [ text expertise.title ]
                , keywords expertise.active []
                    [ strong []
                        <| List.map
                            (\keyword -> text
                                <| String.trim keyword
                                ++ ", "
                            )
                            expertise.keywords
                    ]
                ]
            , body expertise.active []
                [ richText expertise.body
                ]
            ]
