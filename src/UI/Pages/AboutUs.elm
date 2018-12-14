module UI.Pages.AboutUs exposing (..)


import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class, id, src)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (container, siteMargins, slideshow, backgroundImg, image)
import UI.Components.Blocks exposing (richText)
import Wagtail


view : Bool -> Wagtail.AboutUsContent -> Html Msg
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

        contentWrapper =
            styled div
                [ maxWidth (px 820)
                ]

        title =
            styled h1
                [ color (hex "001AE0")
                ]

    in
        wrapper [ if isMobile then id "about-us-page-mobile" else id "about-us-page" ]
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
                    (1, 1, 1)
                    slideImage
                    content.images
                ]
            , container []
                [ bodyText content.bodyText
                ]
            , topics isMobile content.topics
            , team content.team
            , clients content.clients
            ]


slideImage : Wagtail.Image -> Html msg
slideImage image =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , backgroundSize cover
                , backgroundPosition center
                , height (px 300)
                , bpMediumUp
                    [ paddingTop (pct 40)
                    , height zero
                    ]
                ]

    in
        wrapper [ backgroundImg image ] []



bodyText : { left : String, right : String, title : String } -> Html msg
bodyText content =
    let
        left =
            styled div
                [ display block
                , verticalAlign top
                , paddingTop (px 50)
                , bpMediumUp
                    [ padding4 (px 240) (px 180) (px 240) zero
                    , width (pct 66)
                    , display inlineBlock
                    ]
                ]

        right =
            styled h3
                [ display block
                , verticalAlign top
                , paddingBottom (px 50)
                , color (hex "001AE0")
                , bpMediumUp
                    [ padding4 (px 240) zero zero zero
                    , display inlineBlock
                    , width (pct 34)
                    ]
                ]

    in
        siteMargins []
            [ left []
                [ h2 [] [ text content.title ]
                , richText content.left
                ]
            , right [] [ text content.right ]
            ]




topics : Bool -> List Wagtail.Topic -> Html msg
topics isMobile items =
    let
        wrapper =
            styled div
                [ position relative
                , property "display" "flex"
                , flexDirection row
                , position relative
                ]

        title =
            styled h4
                [ display none
                , bpMediumUp
                    [ display block
                    ]
                ]

        animationWrapper =
            styled div
                [ position relative
                , display inlineBlock
                , width (pct 34)
                , transition "all" 0.26 0.0 "ease-in-out"
                , display none
                , bpMediumUp
                    [ display block
                    ]
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

        mobileAnimationWrapper =
            \c ->
                styled div
                    [ backgroundColor (hex c)
                    , height (px 250)
                    , width (vw 100)
                    , left (px -25)
                    , position relative
                    , marginBottom (px 25)
                    , bpMediumUp
                        [ display none
                        ]
                    ]

        mobileTitle =
            styled h2
                [ position absolute
                , top (pct 50)
                , transform <| translateY (pct -50)
                , width (pct 100)
                , padding2 zero (px 25)
                , color (hex "fff")
                , textAlign center
                ]

        mobileAnimation =
            styled div
                [ width (pct 100)
                , height (pct 100)
                ]

        content =
            styled div
                [ position relative
                , display inlineBlock
                , width (pct 100)
                , bpMediumUp
                    [ width (pct 66)
                    ]
                ]

        contentBlock =
            styled div
                [ position relative
                , paddingBottom (px 25)
                , bpMediumUp
                    [ padding (px 140)
                    , firstChild
                        [ paddingTop (px 280)
                        ]
                    , lastChild
                        [ paddingBottom (px 280)
                        ]
                    ]
                ]

    in
        container [ class "topics" ]
            [ siteMargins []
                [ wrapper []
                    [ case isMobile of
                        False -> animationWrapper [ class "animation-wrapper" ]
                                    [ animations []
                                        <| List.indexedMap
                                            (\index t ->
                                                animation
                                                    [ id <| "about-us-animation-" ++ t.animationName
                                                    , class "animation"
                                                    , Html.Styled.Attributes.attribute
                                                        "data-name"
                                                        t.animationName
                                                    ]
                                                    []
                                            )
                                            items
                                    ]
                        True ->
                            text ""
                    , content []
                        <| List.indexedMap
                            (\index t ->
                                contentBlock
                                    [ class "topic"
                                    , Html.Styled.Attributes.attribute
                                        "data-color"
                                        t.color
                                    ]
                                    [ case isMobile of
                                        True ->
                                            mobileAnimationWrapper t.color []
                                                [ mobileAnimation
                                                    [ id <| "about-us-mobile-animation-" ++ t.animationName
                                                    , class "animation"
                                                    , Html.Styled.Attributes.attribute
                                                        "data-name"
                                                        t.animationName
                                                    ]
                                                    []
                                                , mobileTitle [] [ text t.title ]
                                                ]
                                        False ->
                                            text ""
                                    , title [] [ text t.title ]
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
                [ backgroundColor (hex "000")
                , color (hex "fff")
                , position relative
                , paddingTop (px 50)
                , bpMediumUp
                    [ paddingTop (px 240)
                    ]
                ]

        content =
            styled div
                [ maxWidth (px 820)
                ]

    in
        wrapper []
            [ container []
                [ siteMargins []
                    [ content []
                        [ h2 [] [ text data.title ]
                        , p [] [ text data.text ]
                        ]
                    ]
                ]
            , slideshow
                "services-slideshow-team"
                (4, 3, 2)
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
                , bottom (px 20)
                , textAlign center
                , width (pct 100)
                , bpMediumUp
                    [ bottom (px 40)
                    ]
                ]

        image =
            styled div
                [ width (pct 100)
                , backgroundSize contain
                , property "background-position" "center bottom"
                , position relative
                , height (px 340)
                , bpMediumUp
                    [ height (px 660)
                    ]
                , after
                    [ property "content" "''"
                    , position absolute
                    , bottom zero
                    , left zero
                    , width (pct 100)
                    , height (px 200)
                    , backgroundImage
                        <| linearGradient
                            (stop (rgba 0 0 0 0))
                            (stop (rgba 0 0 0 0.5))
                            []
                    ]
                ]

        name =
            styled p
                [ margin zero
                , fontFamilies [ "Qanelas ExtraBold" ]
                , fontSize (px 18)
                , letterSpacing (px 1.5)
                , bpMediumUp
                    [ fontSize (px 28)
                    , letterSpacing (px 2)
                    ]
                ]

        title =
            styled p
                [ margin zero
                , fontSize (px 14)
                , fontWeight (int 800)
                , bpMediumUp
                    [ fontSize (px 22)
                    , letterSpacing (px 1.5)
                    ]
                ]

    in
        wrapper []
            [ image [ backgroundImg data.image ] []
            , content []
                [ name []
                    [ text <| data.firstName ++ " " ++ data.lastName ]
                , title [ ] [ text data.jobTitle ]
                ]
            ]




clients : { title : String, text : String, clients: List Wagtail.Image } -> Html msg
clients data =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "292A32")
                , color (hex "fff")
                , padding2 (px 50) zero
                , bpMediumUp
                    [ padding2 (px 240) zero
                    ]
                ]

        content =
            styled div
                [ maxWidth (px 820)
                ]

        clients =
            styled div
                [ property "display" "flex"
                , flexWrap wrap
                , marginTop (px 25)
                , bpMediumUp
                    [ marginTop (px 50)
                    ]
                ]

        client =
            styled div
                [ display inlineBlock
                , width (pct 50)
                , height (px 140)
                , marginBottom (px 40)
                , textAlign center
                , position relative
                , bpLargeUp
                    [ width (pct 33.3333)
                    ]
                ]

        imageStyle =
            [ maxWidth (pct 80)
            , position absolute
            , left zero
            , top (pct 50)
            , transform
                <| translateY (pct -50)
            , bpMediumUp
                [ transform
                    <| translate2 (pct -50) (pct -50)
                , left (pct 50)
                , maxWidth (pct 90)
                ]
            ]


    in
        wrapper []
            [ container []
                [ siteMargins []
                    [ content []
                        [ h2 [] [ text data.title ]
                        , p [] [ text data.text ]
                        ]
                    , clients []
                        <| List.map
                            (\c ->
                                client [] [ image imageStyle c ]
                            )
                            data.clients
                    ]
                ]
            ]



