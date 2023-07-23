module Data exposing (..)

{- This file records common parameters and tool functions -}

import Color exposing (Color)
import Svg.Attributes exposing (x2, y1, y2)


monsterwidth : Float
monsterwidth =
    75


monsterheight : Float
monsterheight =
    75


monsterLives : Int
monsterLives =
    5


pixelWidth : Float
pixelWidth =
    1000


pixelHeight : Float
pixelHeight =
    1200


paddleWidth : Float
paddleWidth =
    200


paddleSpeed : Float
paddleSpeed =
    800


type Element
    = Water
    | Fire
    | Grass
    | Earth


type Ball_state
    = Carryed
    | Free


type Monster_state
    = Stopped
    | Slow
    | Fast
    | Oscillating


type Boss_state
    = BossStopped
    | BossSlow
    | BossFast
    | BossFight


type alias Monster =
    { idx : Int
    , pos : ( Float, Float )
    , monster_lives : Int
    , monster_score : Int
    , monster_radius : Float
    , element : Element
    , state : Monster_state
    }


type alias Boss =
    { pos : ( Float, Float )
    , boss_radius : Float
    , lives : Int -- Except in the Boss level, the lives of Boss will be initialized as -1 for infinity
    , state : Boss_state
    , element : Element
    , bosstime : Float
    }


type alias Ball =
    { pos : ( Float, Float )
    , radius : Float
    , v_x : Float
    , v_y : Float
    , color : Color
    , element : Element
    , state : Ball_state
    }


type alias Vec =
    ( Float, Float )


type alias Mat =
    ( Vec, Vec )


identityMat : Mat
identityMat =
    ( ( 1, 0 ), ( 0, 1 ) )


addVec : Vec -> Vec -> Vec
addVec ( x1, y1 ) ( x2, y2 ) =
    ( x1 + x2, y1 + y2 )


scaleVec : Float -> Vec -> Vec
scaleVec k ( x, y ) =
    ( k * x, k * y )


innerVec : Vec -> Vec -> Float
innerVec ( x1, y1 ) ( x2, y2 ) =
    x1 * x2 + y1 * y2


reflectionMat : Vec -> Mat
reflectionMat ( bx, by ) =
    let
        t =
            ( ( bx, -by ), ( by, bx ) )

        a =
            ( ( 1, 0 ), ( 0, -1 ) )

        br2 =
            bx ^ 2 + by ^ 2

        t_ =
            ( ( bx / br2, by / br2 ), ( -by / br2, bx / br2 ) )
    in
    multiMatMat (multiMatMat t a) t_


multiMatVec : Mat -> Vec -> Vec
multiMatVec ( a1, a2 ) v =
    ( innerVec a1 v, innerVec a2 v )


multiMatMat : Mat -> Mat -> Mat
multiMatMat ( ( a11, a12 ), ( a21, a22 ) ) ( ( b11, b12 ), ( b21, b22 ) ) =
    ( ( a11 * b11 + a12 * b21, a11 * b12 + a12 * b22 ), ( a21 * b11 + a22 * b21, a21 * b12 + a22 * b22 ) )
