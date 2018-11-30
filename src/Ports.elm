port module Ports exposing (..)
import Types


port updateSlideshow : (String, String) -> Cmd msg


port resetScrollPosition : () -> Cmd msg


port playAnimation : (String, String) -> Cmd msg

port stopAnimation : String -> Cmd msg


port playIntroAnimation : () -> Cmd msg


port scrollOverlayDown : () -> Cmd msg
