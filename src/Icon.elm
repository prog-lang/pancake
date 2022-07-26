module Icon exposing
    ( check
    , exit
    , fail
    , help
    , map
    , ok
    , step
    )

import Color
import Html exposing (Attribute, Html, span)
import Material.Icons exposing (close, done, skip_next)
import Material.Icons.Outlined exposing (flaky, help_outline)
import Material.Icons.Types exposing (Coloring(..))


iconSize : Int
iconSize =
    24


map : List (Attribute msg) -> Html msg -> Html msg
map attrs icon =
    span attrs [ icon ]


help : Html msg
help =
    help_outline iconSize Inherit


check : Html msg
check =
    flaky iconSize (Color <| Color.darkGray)


ok : Html msg
ok =
    done iconSize (Color <| Color.darkGreen)


fail : Html msg
fail =
    close iconSize (Color <| Color.darkRed)


exit : Html msg
exit =
    close iconSize Inherit


step : Html msg
step =
    skip_next iconSize Inherit
