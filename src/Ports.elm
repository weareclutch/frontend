port module Ports exposing (..)


port setupNavigation : () -> Cmd msg


port pauseAllVideos : () -> Cmd msg


port playVideos : () -> Cmd msg


port changeMenuState : String -> Cmd msg


port bindHomePage : () -> Cmd msg


port bindAboutUs : () -> Cmd msg


port bindServicesPage : List String -> Cmd msg


port unbindAll : () -> Cmd msg


port updateSlideshow : (String, String) -> Cmd msg


port resetScrollPosition : () -> Cmd msg


port playAnimation : (String, String) -> Cmd msg


port setupAnimation : (String, String) -> Cmd msg


port stopAnimation : String -> Cmd msg


port playIntroAnimation : () -> Cmd msg


port scrollOverlayDown : () -> Cmd msg

