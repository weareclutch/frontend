module UI.State exposing (MenuState(..), Msg(..))

type MenuState
    = Closed
    | OpenTop
    | OpenBottom
    | OpenTopContact
    | OpenBottomContact


type Msg
    = OpenMenu MenuState
    | ToggleMenu
    | OpenContact


