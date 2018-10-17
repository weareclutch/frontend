port module Ports exposing (..)

import Types exposing (..)

port resetScrollPosition : () -> Cmd msg

port playAnimation : () -> Cmd msg

port scrollOverlayDown : () -> Cmd msg

