port module Ports exposing (updateSlideshow, playAnimation, resetScrollPosition, scrollOverlayDown)
import Types


port updateSlideshow : (String, String) -> Cmd msg


port resetScrollPosition : () -> Cmd msg


port playAnimation : () -> Cmd msg


port scrollOverlayDown : () -> Cmd msg
