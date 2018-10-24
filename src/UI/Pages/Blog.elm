module UI.Pages.Blog exposing (overview, collection, post)

import Html.Styled exposing (..)
import Css exposing (..)
import Style exposing (..)
import UI.Common exposing (addLink)
import Types exposing (Msg)

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
    in
        wrapper []
            [ h2 (addLink "/blog/chatbot-series/") [ text "to blog series" ]
            , h2 (addLink "/blog/blog-post-non-series/") [ text "to blog post" ]
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


