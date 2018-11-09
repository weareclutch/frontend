port module Ports exposing (playAnimation, resetScrollPosition, scrollOverlayDown)

import Types exposing (..)


port resetScrollPosition : () -> Cmd msg


port playAnimation : () -> Cmd msg


port scrollOverlayDown : () -> Cmd msg
