module UI.Pages.Blog exposing (collection, overview, post)

import Css exposing (..)
import Html.Styled exposing (..)
import Style exposing (..)
import Types exposing (Msg)
import UI.Common exposing (addLink)
import Wagtail


overview : Wagtail.BlogOverviewContent -> Html Msg
overview content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                ]

        makeListLink s =
            li (addLink s.slug) [ text s.title ]

        series =
            List.map
                makeListLink
                content.blogSeries

        posts =
            List.map
                makeListLink
                content.blogPosts
    in
    wrapper []
        [ h2 [] [ text " blog series" ]
        , ol [] series
        , h2 [] [ text " blog posts" ]
        , ol [] posts
        ]


collection : Wagtail.BlogCollectionContent -> Html msg
collection content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                ]
    in
    wrapper []
        [ h1 [] [ text "blog collection" ]
        ]


post : Wagtail.BlogPostContent -> Html msg
post content =
    let
        wrapper =
            styled div
                [ backgroundColor (hex "fff")
                , minHeight (pct 100)
                , minWidth (pct 100)
                ]
    in
    wrapper []
        [ h1 [] [ text "blog post" ]
        ]
