module MyElement exposing (..)

import Data exposing (Element(..))

elementMatch : Element -> Element -> Int
elementMatch ball_elem monster_elem =
    let
        match =
            ( ball_elem, monster_elem )
    in
    case match of
        ( Water, Fire ) ->
            4

        ( Fire, Grass ) ->
            4

        ( Grass, Earth ) ->
            4

        ( Earth, Water ) ->
            4

        ( Fire, Water ) ->
            1

        ( Grass, Fire ) ->
            1

        ( Earth, Grass ) ->
            1

        ( Water, Earth ) ->
            1

        _ ->
            2
element2String : Element -> String
element2String elem =
    case elem of
        Water ->
            "water"

        Fire ->
            "fire"

        Grass ->
            "grass"

        Earth ->
            "earth"

element2ColorString : Element -> String
element2ColorString elem =
    case elem of
        Water ->
            "blue"

        Fire ->
            "red"

        Grass ->
            "green"

        Earth ->
            "gold"
