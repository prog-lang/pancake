module Terminal.Class exposing
    ( half
    , stack
    , stackFrame
    , world
    , worldUnknown
    )

import Html exposing (Attribute)
import Html.Attributes exposing (class)


terminal : String -> Attribute msg
terminal string =
    class <| "terminal-" ++ string


half : Attribute msg
half =
    terminal "half"


world : Attribute msg
world =
    terminal "world"


worldUnknown : Attribute msg
worldUnknown =
    terminal "world-unknown"


stack : Attribute msg
stack =
    terminal "stack"


stackFrame : Attribute msg
stackFrame =
    terminal "stack-frame"
