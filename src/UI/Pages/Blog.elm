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
