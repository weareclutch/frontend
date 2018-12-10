module UI.Pages.AboutUs exposing (..)


import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, id, src)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (container, siteMargins, slideshow, backgroundImg, image)
import UI.Components.Blocks exposing (richText)
import Wagtail


view : Wagtail.AboutUsContent -> Html Msg
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
        wrapper [ id "about-us-page" ]
            [ container []
                [ siteMargins []
                    [ title [] [ text content.title ]
                    , p [ class "intro" ] [ text content.introduction ]
                    ]
                ]
            , slideshowWrapper []
                [ slideshow
                    "services-slideshow"
                    (1, 1, 1)
                    slideImage
                    content.images
                ]
            , container []
                [ bodyText content.bodyText
                ]
            , topics content.topics
            , team content.team
            , clients content.clients
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



bodyText : { left : String, right : String } -> Html msg
bodyText content =
    let
        left =
            styled div
                [ display inlineBlock
                , width (pct 66)
                , verticalAlign top
                , padding4 (px 240) (px 180) (px 240) zero
                ]

        right =
            styled h3
                [ display inlineBlock
                , width (pct 34)
                , verticalAlign top
                , color (hex "001AE0")
                , paddingTop (px 240)
                ]

    in
        siteMargins []
            [ left [] [ richText content.left ]
            , right [] [ text content.right ]
            ]




topics : List Wagtail.Topic -> Html msg
topics items =
    let
        wrapper =
            styled div
                [ position relative
                , property "display" "flex"
                , flexDirection row
                , position relative
                ]

        animationWrapper =
            styled div
                [ position relative
                , display inlineBlock
                , width (pct 34)
                , transition "all" 0.26 0.0 "ease-in-out"
                , after
                    [ property "content" "''"
                    , display block
                    , position absolute
                    , backgroundColor inherit
                    , top zero
                    , right zero
                    , height (pct 100)
                    , width (vw 50)
                    , zIndex (int 1)
                    ]
                ]

        animations =
            styled div
                [ position sticky
                , width (pct 100)
                , height (px 620)
                , top <| calc (pct 50) minus (px 320)
                , borderRadius (pct 50)
                , margin2 (px 40) auto
                , zIndex (int 10)
                , bpXXLargeUp
                    [ property "width" "calc(((-100vw - -1520px) / 2) + 140%)"
                    ]
                ]

        animation =
            styled div
                [ position absolute
                , top zero
                , transition "all" 0.26 0.0 "ease-in-out"
                , left (px -140)
                , bpXXLargeUp
                    [ property "left" "calc((-100vw - -1520px) / 2)"
                    ]
                ]


        content =
            styled div
                [ position relative
                , display inlineBlock
                , width (pct 66)
                ]

        contentBlock =
            styled div
                [ padding (px 140)
                , firstChild
                    [ paddingTop (px 280)
                    ]
                , lastChild
                    [ paddingBottom (px 280)
                    ]
                ]

    in
        container [ class "topics" ]
            [ siteMargins []
                [ wrapper []
                    [ animationWrapper [ class "animation-wrapper" ]
                        [ animations []
                            <| List.indexedMap
                                (\index t ->
                                    animation
                                        [ id <| "about-us-animation-" ++ (toString index)
                                        , class "animation"
                                        , Html.Styled.Attributes.attribute
                                            "data-name"
                                            "foo"
                                        ]
                                        []
                                )
                                items
                        ]
                    , content []
                        <| List.map
                            (\t ->
                                contentBlock
                                    [ class "topic"
                                    , Html.Styled.Attributes.attribute
                                        "data-color"
                                        t.color
                                    ]
                                    [ h4 [] [ text t.title ]
                                    , richText t.description
                                    ]
                            )
                            items
                    ]
               ]
          ]



team : { title : String , text : String , people : List Wagtail.Person } -> Html Msg
team data =
    let
        wrapper =
            styled div
                [ height (vh 100)
                , backgroundColor (hex "000")
                , color (hex "fff")
                , paddingTop (px 240)
                ]


    in
        wrapper []
            [ container []
                [ siteMargins []
                    [ h2 [] [ text data.title ]
                    , p [] [ text data.text ]
                    ]
                ]
            , slideshow
                "services-slideshow-team"
                (3, 2, 1)
                person
                data.people
            ]


person : Wagtail.Person -> Html msg
person data =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , position relative
                ]

        content =
            styled p
                [ position absolute
                , bottom (px 40)
                , textAlign center
                , width (pct 100)
                ]

        image =
            styled div
                [ height (px 660)
                , width (pct 100)
                , backgroundSize contain
                , backgroundPosition center
                ]

    in
        wrapper []
            [ image [ backgroundImg data.image ] []
            , content []
                [ span [] [ text <| data.firstName ++ " " ++ data.lastName ]
                , br [] []
                , span [] [ text data.jobTitle ]
                ]
            ]




clients : { title : String, text : String, clients: List Wagtail.Image } -> Html msg
clients data =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "292A32")
                , padding2 (px 240) zero
                , color (hex "fff")
                ]

        clients =
            styled div
                [ property "display" "flex"
                , flexWrap wrap
                ]

        client =
            styled div
                [ display inlineBlock
                , width (pct 100)
                , marginBottom (px 40)
                , bpMedium
                    [ width (pct 50)
                    ]
                , bpLargeUp
                    [ width (pct 33.333)
                    ]
                ]

    in
        wrapper []
            [ container []
                [ siteMargins []
                    [ h2 [] [ text data.title ]
                    , p [] [ text data.text ]
                    , clients []
                        <| List.map
                            (\c ->
                                client []
                                    [ image [ width (pct 100) ] c
                                    ]
                            )
                            data.clients
                    ]
                ]
            ]



