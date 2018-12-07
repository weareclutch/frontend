port module Ports exposing (..)

port bindAboutUs : () -> Cmd msg


port unbindAll : () -> Cmd msg


port updateSlideshow : (String, String) -> Cmd msg


port resetScrollPosition : () -> Cmd msg


port playAnimation : (String, String) -> Cmd msg


port stopAnimation : String -> Cmd msg


port playIntroAnimation : () -> Cmd msg


port scrollOverlayDown : () -> Cmd msg
