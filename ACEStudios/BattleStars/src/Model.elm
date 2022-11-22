module Model exposing (State(..), Model, initLevel, reModel, detVelocity, detVelocityBoss, generateBall, init)

import Browser.Dom exposing (getViewport)
import Data exposing (Monster, Monster_state(..), Ball_state(..), Ball, Boss, Boss_state(..), Element(..), addVec, monsterLives, paddleWidth, pixelWidth )
import Messages exposing (..)
import Paddle exposing (..)
import Random exposing (..)
import Scoreboard exposing (..)
import Task


type State
    = Starting
    | Playing Int -- Playing will be switched to Playing1, Playing2 (different levels)
    | Scene Int
    | ClearLevel Int -- Input level integer
    | Gameover Int


type alias Model =
    { monster_list : List Monster
    , boss : Boss
    , paddle : Paddle
    , ball_list : List Ball
    , ballnumber : Int
    , time : Float
    , lives : Int
    , scores : Int
    , level_scores : Int
    , state : State
    , size : ( Float, Float )
    , seed : Seed
    , level : Int
    , extraMonster : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel
    , Task.perform GetViewport getViewport
    )


initModel : Model
initModel =
    { monster_list = initMonsterList 1 4 --one life for each monster; 10 points for each monster
    , boss = initBoss 1
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 1 1)
    , ballnumber = 1
    , time = 0
    , lives = 5 --five lives for a player
    , scores = 0
    , level_scores = 0
    , state = Scene 0
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 1
    , extraMonster = 0
    }

reModel : Model
reModel =
    let
        nmodel = initModel
    in
    {nmodel | state = Starting}


initLevel : Int -> Model -> Model
initLevel k model =
    case k of
        1 ->
            model_1 model

        2 ->
            model_2 model

        3 ->
            model_3 model

        4 ->
            model_4 model

        _ ->
            model_boss model


model_1 : Model -> Model
model_1 model =
    { monster_list = initMonsterList 1 4 --one life for each monster; 10 points for each monster
    , boss = initBoss 1
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 1 2)
    , ballnumber = 1
    , time = 0
    , lives = 5 --five lives for a player
    , scores = model.scores
    , level_scores = 0
    , state = Playing 1
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 1
    , extraMonster = 0
    }


model_2 : Model -> Model
model_2 model =
    { monster_list = initMonsterList 2 15 --one life for each monster; 10 points for each monster
    , boss = initBoss 2
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 1 4)
    , ballnumber = 1
    , time = 0
    , lives = 5 --five lives for a player
    , scores = model.scores
    , level_scores = 0
    , state = Playing 2
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 2
    , extraMonster = 0
    }


model_3 : Model -> Model
model_3 model =
    { monster_list = initMonsterList 3 16 --one life for each monster; 10 points for each monster
    , boss = initBoss 3
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 1 4)
    , ballnumber = 1
    , time = 0
    , lives = 5 --five lives for a player
    , scores = model.scores
    , level_scores = 0
    , state = Playing 3
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 3
    , extraMonster = 0
    }


model_4 : Model -> Model
model_4 model =
    { monster_list = initMonsterList 4 16 --one life for each monster; 10 points for each monster
    , boss = initBoss 4
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 2 4)
    , ballnumber = 2
    , time = 0
    , lives = 5 --five lives for a player
    , scores = model.scores
    , level_scores = 0
    , state = Playing 4
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 4
    , extraMonster = 0
    }


model_boss : Model -> Model
model_boss model =
    { monster_list = initMonsterList 5 4 --one life for each monster; 10 points for each monster
    , boss = initBoss 5
    , paddle = initpaddle
    , ball_list = List.map Tuple.first (generateBallList initpaddle 2 4)
    , ballnumber = 2
    , time = 0
    , lives = 5 --five lives for a player
    , scores = model.scores
    , level_scores = 0
    , state = Playing 6
    , size = ( 2000, 1000 )
    , seed = Random.initialSeed 1234
    , level = 5
    , extraMonster = 0
    }


generateBallList : Paddle -> Int -> Int -> List ( Ball, Seed )
generateBallList paddle ballNum elemNum =
    case ballNum of
        0 ->
            []

        _ ->
            generateBallList paddle (ballNum - 1) elemNum ++ [ generateBall paddle (Random.initialSeed 1234) elemNum ]


generateBall : Paddle -> Seed -> Int -> ( Ball, Seed )
generateBall paddle seed elemNum =
    let
        elemlist =
            case elemNum of
                1 ->
                    []

                2 ->
                    [ Fire ]

                3 ->
                    [ Fire, Grass ]

                _ ->
                    [ Fire, Grass, Earth ]

        ( elem, nseed ) =
            Random.step
                (Random.uniform Water
                    elemlist
                )
                seed

        ( x, y ) =
            addVec paddle.pos ( paddle.width / 2, -15 )
    in
    ( Ball ( x, y ) 15 0 0 { red = 0, green = 0, blue = 0 } elem Carryed, nseed )


initMonsterList : Int -> Int -> List Monster
initMonsterList level n =
    case n of
        0 ->
            []

        _ ->
            initMonsterList level (n - 1) ++ [ initMonster level n ]


initBoss : Int -> Boss
initBoss level =
    case level of
        1 ->
            Boss ( 500, -900 ) 1250 -10 BossStopped Water 0

        3 ->
            Boss ( 500, -1250 ) 1250 -10 BossFast Water 0

        5 ->
            Boss ( 500, -900 ) 1250 100 BossFight Water 0

        _ ->
            Boss ( 500, -1250 ) 1250 -10 BossSlow Water 0


initpaddle : Paddle
initpaddle =
    { pos = ( 500, 1000 ), moveLeft = False, moveRight = False, latestDir = Left, height = 40, width = paddleWidth, speed = 1000, move_range = pixelWidth }



-- radius of monster is likely to be adjust to a suitable size later


initMonster : Int -> Int -> Monster
initMonster level idx =
    let
        state =
            case level of
                1 ->
                    Stopped

                2 ->
                    Slow

                3 ->
                    Fast

                _ ->
                    Oscillating
    in
    Monster idx (detPosition level idx) monsterLives 10 60 (detElem level idx) state


detPosition : Int -> Int -> ( Float, Float )
detPosition level idx =
    case level of
        1 ->
            ( toFloat idx * 200, 450 )

        2 ->
            let
                row =
                    (idx - 1) // 5

                column =
                    modBy 5 (idx - 1) + 1
            in
            ( toFloat column * 166, toFloat row * 166 + 100 )

        3 ->
            let
                row =
                    (idx - 1) // 4

                column =
                    modBy 4 (idx - 1) + 1
            in
            case modBy 2 row of
                0 ->
                    ( toFloat column * 200 - 50, toFloat row * 173 + 100 )

                _ ->
                    ( 1000 - (toFloat column * 200 - 50), toFloat row * 173 + 100 )

        4 ->
            let
                row =
                    (idx - 1) // 4

                column =
                    modBy 4 (idx - 1) + 1
            in
            case modBy 2 row of
                0 ->
                    ( toFloat column * 200 - 50, toFloat row * 173 + 100 )

                _ ->
                    ( 1000 - (toFloat column * 200 - 50), toFloat row * 173 + 100 )

        _ ->
            ( toFloat idx * 200, 550 )


detElem : Int -> Int -> Element
detElem level idx =
    case level of
        1 ->
            case modBy 2 idx of
                1 ->
                    Water

                _ ->
                    Fire

        2 ->
            case modBy 2 idx of
                1 ->
                    Earth

                _ ->
                    Grass

        _ ->
            case modBy 4 idx of
                1 ->
                    Water

                2 ->
                    Fire

                3 ->
                    Grass

                _ ->
                    Earth


detVelocity : Monster -> Model -> ( Float, Float )
detVelocity monster model =
    case model.state of
        Gameover _ ->
            ( 0, 0 )

        _ ->
            case monster.state of
                Slow ->
                    ( 0, 10 )

                Fast ->
                    ( 0, 15 )

                Oscillating ->
                    ( 80 * cos model.time, 10 )

                _ ->
                    ( 0, 0 )


detVelocityBoss : Boss -> State -> ( Float, Float )
detVelocityBoss boss state =
    case state of
        Gameover _ ->
            ( 0, 0 )

        _ ->
            case boss.state of
                BossSlow ->
                    ( 0, 10 )

                BossFast ->
                    ( 0, 15 )

                _ ->
                    ( 0, 0 )
