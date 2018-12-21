module UI.Pages.Blog exposing (collection, overview, post)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (class)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (container, image, addLink, backgroundImg, siteMargins, slideshow)
import UI.Components.Blocks exposing (richText)
import Wagtail


seriesPreview : Wagtail.BlogSeriesPreview -> Html Msg
seriesPreview preview =
    let
        outerWrapper =
            styled div
                [ position relative
                , cursor pointer
                , marginRight (px 40)
                ]

        wrapper =
            styled div
                [ color (hex "fff")
                , display inlineBlock
                , position relative
                , verticalAlign top
                , paddingTop (pct 150)
                ]

        content =
            styled div
                [ position absolute
                , bottom zero
                , padding4 zero (px 25) (px 50) (px 25)
                , textShadow4 zero (px 15) (px 30) (rgba 0 0 0 0.4)
                ]

    in
        outerWrapper
            (
                backgroundImg preview.image
                :: (addLink preview.slug)
            )
            [ wrapper []
                [ content []
                    [ h3 [] [ text preview.title ]
                    , p []
                        [ text
                            <| (toString preview.seriesSize)
                            ++ " artikelen"
                        ]
                    ]
                ]
            ]



postPreview : Wagtail.BlogPostPreview -> Html Msg
postPreview preview =
    let
        wrapper =
            styled div
                [ width (pct 100)
                , maxWidth (px 1360)
                , position relative
                , height auto
                , cursor pointer
                , marginBottom (px 25)
                , property "display" "flex"
                , minHeight (px 85)
                , bpMediumUp
                    [ minHeight (px 300)
                    , marginBottom (px 68)
                    ]
                ]

        img =
            styled div
                [ height zero
                , display inlineBlock
                , verticalAlign top
                , backgroundSize cover
                , backgroundPosition center
                , height zero
                , width (pct 30)
                , paddingTop (pct 30)
                , bpMediumUp
                    [ width (pct 33)
                    , paddingTop (pct 33)
                    ]
                ]

        content =
            styled div
                [ width (pct 67)
                , display inlineBlock
                , verticalAlign top
                , padding2 zero (px 10)
                , bpMediumUp
                    [ padding (px 40)
                    ]
                ]

        intro =
            styled div
                [ display none
                , bpMediumUp
                    [ display block
                    ]
                ]

        time =
            styled strong
              [ color (hex "001AE0")
              ]


    in
    wrapper
        (addLink preview.slug)
        [ img [ backgroundImg preview.image ] []
        , content []
            [ h3 [] [ text preview.title ]
            , time [ class "tags" ]
                [ text
                    <| toString preview.readingTime
                    ++ " minuten"
                ]
            , intro [] [ richText preview.intro ]
            ]
        ]





overview : Wagtail.BlogOverviewContent -> Html Msg
overview content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                , padding4 (px 130) zero (px 10) zero
                , bpMediumUp
                    [ padding4 (pct 20) zero (px 10) zero
                    ]
                ]


        title =
            styled h1
                [ color (hex "001AE0")
                ]

        series =
            content.blogSeries
                |> slideshow
                    "blog-series-slideshow"
                    (4, 3, 2)
                    seriesPreview

        posts =
            List.map
                postPreview
                content.blogPosts

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
        --, series
        , container []
            [ siteMargins []
                [ div [] posts
                ]
            ]
        ]


collection : Wagtail.BlogCollectionContent -> Html Msg
collection content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                ]

        innerWrapper  =
            styled div
                [ minHeight (pct 100)
                , padding2 (px 270) zero
                , maxWidth (px 1130)
                , margin auto
                ]

        title =
            styled h2
                [ color (hex "001AE0")
                ]

        posts =
            List.map
                postPreview
                content.blogPosts
    in
    wrapper []
        [ container []
            [ siteMargins []
                [ innerWrapper []
                    [ title [] [ text content.title ]
                    , div [ class "intro" ] [ richText content.intro ]
                    , div [] posts
                    ]
                ]
            ]
        ]


post : Wagtail.BlogPostContent -> Html Msg
post content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                ]

        innerWrapper  =
            styled div
                [ minHeight (pct 100)
                , padding2 (px 270) zero
                , maxWidth (px 1360)
                , margin auto
                ]

        title =
            styled h2
                [ color (hex "001AE0")
                ]

        footer =
            styled div
                [ backgroundColor (hex "292A32")
                ]

    in
        wrapper []
            [ container []
                [ innerWrapper []
                    [ siteMargins [] 
                        [ title [] [ text content.title ]
                        , p []
                            [ strong []
                                [ text
                                    <| (toString content.readingTime)
                                    ++ " minuten leestijd"
                                ]
                            ]
                        , p [ class "intro" ] [ text content.intro ]
                        ]
                    , content.body
                        |> Maybe.map renderPostBlocks
                        |> Maybe.withDefault (text "")
                    ]
                ]
            , footer []
                [ siteMargins []
                    [
                    ]
                ]
            ]


renderPostBlocks : List Wagtail.Block -> Html msg
renderPostBlocks blocks =
    blocks
        |> List.map
            (\block ->
                case block of
                    Wagtail.QuoteBlock data ->
                        renderQuote data

                    Wagtail.ImageBlock _ image ->
                        renderImage image

                    Wagtail.BackgroundBlock image ->
                        renderBackground image

                    Wagtail.ContentBlock _ content ->
                        renderContent content

                    _ ->
                        div [] []

            )
        |> (div [])


renderQuote : Wagtail.Quote -> Html msg
renderQuote data =
    let
        title =
            styled h3
                [ color (hex "001AE0")
                ]

        wrapper =
            styled div
                [ maxWidth (px 850)
                , margin auto
                , padding2 zero (px 25)
                ]
    in
        wrapper []
            [ title [] [ text data.text ]
            , data.name
                |> Maybe.map
                    (\name ->
                        p [] [ text ("- " ++ name) ]
                    )
                |> Maybe.withDefault (text "")
            ]


renderImage : Wagtail.Image -> Html msg
renderImage img =
    let
        wrapper =
            styled div
                [ maxWidth (px 1080)
                , padding2 zero (px 25)
                , margin auto
                ]

        caption =
            styled p
                [ color (hex "BBBBBB")
                , marginTop (px 10)
                ]
    in
        wrapper []
            [ image
                [ width (pct 100)
                ]
                img
            , img.caption 
                |> Maybe.map
                    (\c -> 
                        caption [ class "tags" ] [ text c ]
                    )
                |> Maybe.withDefault (text "")
            ]


renderBackground : Wagtail.Image -> Html msg
renderBackground img =
    div []
        [ image
            [ width (pct 100)
            ]
            img
        ]


renderContent : String -> Html msg
renderContent text =
    let
        wrapper =
            styled div
                [ maxWidth (px 850)
                , margin auto
                , padding2 zero (px 25)
                ]

    in
        wrapper []
            [ richText text
            ]


