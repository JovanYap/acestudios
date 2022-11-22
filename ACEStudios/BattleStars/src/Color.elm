module Color exposing (Color, getColorful, getcolor)

import String exposing (fromInt)


type alias Color =
    { red : Int
    , green : Int
    , blue : Int
    }


getColorful : Float -> Color
getColorful time =
    let
        r =
            round ((sin (0.5 * time) + 1) / 2 * 255)

        g =
            round ((sin ((0.5 * time) + 3.14 * 2 / 3) + 1) / 2 * 255)

        b =
            round ((sin ((0.5 * time) + 3.14 * 4 / 3) + 1) / 2 * 255)
    in
    Color r g b


getcolor : Color -> String
getcolor color =
    let
        r =
            fromInt color.red

        g =
            fromInt color.green

        b =
            fromInt color.blue
    in
    "rgb(" ++ r ++ "," ++ g ++ "," ++ b ++ ")"
