module UI.Common exposing (link)

import Types exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Json.Decode as Decode


link : String -> List (Html Msg) -> Html Msg
link url children =
    let
        options =
            { stopPropagation = False
            , preventDefault = True
            }

        message =
            ChangeLocation url

        onLinkClick =
            onWithOptions "click" options (Decode.succeed message)
    in
        a [ (href url), onLinkClick ] children
