port module Ports exposing (bindAboutUs, bindCasePage, bindHomePage, bindServicesPage, changeMenuState, pauseAllVideos, playAnimation, playHoverAnimation, playIntroAnimation, playVideos, resetScrollPosition, scrollToCases, setupAnimation, setupNavigation, stopAnimation, unbindAll, updateSlideshow)


port setupNavigation : () -> Cmd msg


port pauseAllVideos : () -> Cmd msg


port playVideos : () -> Cmd msg


port changeMenuState : String -> Cmd msg


port playBurgerAnimation : ( Int, Int ) -> Cmd msg


port bindHomePage : List String -> Cmd msg


port bindCasePage : () -> Cmd msg


port bindAboutUs : () -> Cmd msg


port bindServicesPage : List String -> Cmd msg


port unbindAll : () -> Cmd msg


port updateSlideshow : ( String, String ) -> Cmd msg


port resetScrollPosition : () -> Cmd msg


port playAnimation : ( String, String ) -> Cmd msg


port setupAnimation : ( String, String ) -> Cmd msg


port stopAnimation : String -> Cmd msg


port playIntroAnimation : () -> Cmd msg


port playHoverAnimation : () -> Cmd msg


port scrollToCases : () -> Cmd msg
