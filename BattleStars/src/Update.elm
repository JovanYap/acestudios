module Update exposing (update)

import Bounce exposing (Bounce(..), newBounceVelocity, newReflectedVelocity, updateMonster)
import Browser.Dom exposing (getViewport)
import Data exposing (Ball, Ball_state(..), Boss, Boss_state(..), Element(..), Mat, Monster, Monster_state(..), addVec, identityMat, innerVec, monsterLives, reflectionMat, scaleVec)
import Messages exposing (..)
import Model exposing (..)
import MyElement exposing (elementMatch)
import Paddle exposing (..)
import Random
import Scoreboard exposing (..)
import Svg.Attributes exposing (by)
import Task


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Restart ->
            ( initLevel model.level model, Task.perform GetViewport getViewport )

        Resize width height ->
            ( { model | size = ( toFloat width, toFloat height ) }
            , Cmd.none
            )

        Start ->
            updateScene model

        GetViewport { viewport } ->
            ( { model
                | size =
                    ( viewport.width
                    , viewport.height
                    )
              }
            , Cmd.none
            )

        Enter False ->
            case model.state of
                Scene _ ->
                    updateScene model

                _ ->
                    ( model, Cmd.none )

        NextScene ->
            updateClearLevel model

        Skip ->
            case model.state of
                Playing _ ->
                    ( { model | state = ClearLevel model.level, monster_list = [] }, Task.perform GetViewport getViewport )

                _ ->
                    ( model, Cmd.none )

        Shoot False ->
            ( shootBall model, Cmd.none )

        GenerateMonster elem ( nx, ny ) ->
            let
                idx =
                    Maybe.withDefault 0 (List.maximum (List.map .idx model.monster_list))

                nmonster =
                    Monster (idx + 1) ( nx, ny ) monsterLives 10 60 elem Oscillating

                condition =
                    model.monster_list
                        |> List.all (\monster -> (Tuple.first monster.pos - nx) ^ 2 + (Tuple.second monster.pos - ny) ^ 2 >= 130 ^ 2)
            in
            if condition then
                ( { model | extraMonster = model.extraMonster + 1, monster_list = nmonster :: model.monster_list }, Cmd.none )

            else
                ( model, Random.generate (GenerateMonster model.boss.element) randomPos )

        Key Left on ->
            let
                paddle =
                    model.paddle

                newpaddle =
                    { paddle | moveLeft = on }
            in
            ( { model | paddle = newpaddle }, Cmd.none )

        Key Right on ->
            let
                paddle =
                    model.paddle

                newpaddle =
                    { paddle | moveRight = on }
            in
            ( { model | paddle = newpaddle }, Cmd.none )

        _ ->
            ( model, Cmd.none )
                |> updatePaddle msg
                |> updateBall
                |> moveStuff msg
                |> changeBossElement
                |> generateMonster
                |> updateTime msg
                |> checkFail
                |> checkBallNumber
                |> checkEnd


updateScene : Model -> ( Model, Cmd Msg )
updateScene model =
    case model.state of
        Starting ->
            let
                nModel =
                    model
            in
            ( { nModel | state = Scene 2, time = 0 }, Task.perform GetViewport getViewport )

        Scene 0 ->
            let
                nModel =
                    model
            in
            ( { nModel | state = Scene 1, time = 0 }, Task.perform GetViewport getViewport )

        Scene 1 ->
            let
                nModel =
                    model
            in
            ( { nModel | state = Starting, time = 0 }, Task.perform GetViewport getViewport )

        Scene 7 ->
            ( reModel, Task.perform GetViewport getViewport )

        Scene k ->
            ( initLevel (k - 1) model, Task.perform GetViewport getViewport )

        _ ->
            ( model, Task.perform GetViewport getViewport )



{- The clear level shows the score after completing one level -}


updateClearLevel : Model -> ( Model, Cmd Msg )
updateClearLevel model =
    case model.state of
        ClearLevel a ->
            ( { model | state = Scene (a + 2), time = 0 }, Task.perform GetViewport getViewport )

        _ ->
            ( model, Task.perform GetViewport getViewport )


updatePaddle : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updatePaddle msg ( model, cmd ) =
    case msg of
        Tick elapse ->
            ( { model
                | paddle =
                    movePaddle model.paddle (elapse / 1000)
              }
            , cmd
            )

        _ ->
            ( model, Cmd.none )


shootBall : Model -> Model
shootBall model =
    let
        ( carryedBall, freeBall ) =
            List.partition (\ball -> ball.state == Carryed) model.ball_list

        shootedBall =
            List.head carryedBall

        otherBall =
            List.drop 1 carryedBall ++ freeBall
    in
    case shootedBall of
        Just ball ->
            { model | ball_list = { ball | state = Free, v_y = -600 } :: otherBall }

        Nothing ->
            model


updateBall : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateBall ( model, cmd ) =
    bounceAll ( model, cmd )


moveStuff : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
moveStuff msg ( model, cmd ) =
    case msg of
        Tick elapsed ->
            ( model
                |> moveBall (elapsed / 1000)
                |> moveMonster (elapsed / 1000)
                |> moveBoss (elapsed / 1000)
            , cmd
            )

        _ ->
            ( model, cmd )


moveBall : Float -> Model -> Model
moveBall dt model =
    let
        nball_list =
            List.map (moveEachBall dt model.paddle) model.ball_list
    in
    { model | ball_list = nball_list }


moveEachBall : Float -> Paddle -> Ball -> Ball
moveEachBall dt paddle ball =
    case ball.state of
        Free ->
            { ball | pos = addVec ball.pos ( ball.v_x * dt, ball.v_y * dt ) }

        Carryed ->
            { ball | pos = addVec paddle.pos ( paddle.width / 2, -15 ) }


moveMonster : Float -> Model -> Model
moveMonster dt model =
    let
        nmonster_list =
            model.monster_list
                |> List.map (\monster -> { monster | pos = addVec monster.pos (scaleVec dt (detVelocity monster model)) })
    in
    monsterHitSurface { model | monster_list = nmonster_list }


changeBossElement : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
changeBossElement ( model, cmd ) =
    let
        boss =
            model.boss
    in
    if boss.bosstime >= 5 then
        ( { model | boss = nextBossElement { boss | bosstime = 0 } model.level }, cmd )

    else
        ( model, cmd )


nextBossElement : Boss -> Int -> Boss
nextBossElement boss level =
    let
        nelem =
            nextElement boss.element level
    in
    { boss | element = nelem }


nextElement : Element -> Int -> Element
nextElement elem level =
    case level of
        1 ->
            case elem of
                Water ->
                    Fire

                _ ->
                    Water

        _ ->
            case elem of
                Water ->
                    Fire

                Fire ->
                    Grass

                Grass ->
                    Earth

                _ ->
                    Water


generateMonster : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
generateMonster ( model, cmd ) =
    case model.boss.state of
        BossFight ->
            if model.time > 2.5 * toFloat model.extraMonster then
                ( model, Cmd.batch [ cmd, Random.generate (GenerateMonster model.boss.element) randomPos ] )

            else
                ( model, cmd )

        _ ->
            ( model, cmd )


randomPos : Random.Generator ( Float, Float )
randomPos =
    Random.pair (Random.float 100 900) (Random.float 450 550)


monsterHitSurface : Model -> Model
monsterHitSurface model =
    let
        ( dead, alive ) =
            model.monster_list
                |> List.partition (\{ pos } -> Tuple.second pos >= 920)

        deducted_lives =
            2 * List.length dead

        prev_lives =
            model.lives
    in
    { model | monster_list = alive, lives = prev_lives - deducted_lives }


moveBoss : Float -> Model -> Model
moveBoss dt model =
    let
        boss =
            model.boss

        nboss =
            { boss | pos = addVec boss.pos (scaleVec dt (detVelocityBoss boss model.state)) }
    in
    { model | boss = nboss }


bounceAll : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
bounceAll ( model, cmd ) =
    ( model, cmd )
        |> bouncePaddle
        |> bounceScreen
        |> bounceMonster
        |> bounceBoss


bouncePaddle : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
bouncePaddle ( model, cmd ) =
    let
        nball_list =
            List.map2 newBounceVelocity model.ball_list (List.map (checkBouncePaddle <| model.paddle) model.ball_list)
    in
    ( { model | ball_list = nball_list }, cmd )



--wyj


checkBouncePaddle : Paddle -> Ball -> Bounce
checkBouncePaddle paddle ball =
    let
        r =
            ball.radius

        ( bx, by ) =
            ball.pos

        ( px, py ) =
            paddle.pos

        wid =
            paddle.width
    in
    if ball.v_y > 0 then
        if by <= py && by + r >= py && bx >= px && bx <= px + wid then
            Paddle_Bounce (bx - px)

        else if bx <= px && bx + r >= px && by >= py && by <= py + paddle.height then
            Paddle_Bounce 0

        else if bx >= px + paddle.width && bx - r <= px + paddle.width && by >= py && by <= py + paddle.height then
            Paddle_Bounce (px + paddle.width)

        else
            None

    else
        None


bounceScreen : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
bounceScreen ( model, cmd ) =
    let
        nball_list =
            List.map2 newBounceVelocity model.ball_list (List.map checkBounceScreen model.ball_list)
    in
    ( { model | ball_list = nball_list }, cmd )


checkBounceScreen : Ball -> Bounce
checkBounceScreen ball =
    let
        r =
            ball.radius

        ( x, y ) =
            ball.pos
    in
    if y - r <= 0 && ball.v_y < 0 then
        Horizontal

    else if (x - r <= 0 && ball.v_x < 0) || (x + r >= 1000 && ball.v_x > 0) then
        Vertical

    else
        None


changeElement : Ball -> Maybe Monster -> Ball
changeElement ball monster =
    case monster of
        Just bk ->
            { ball
                | element = bk.element
            }

        Nothing ->
            ball


bounceMonster : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
bounceMonster ( model, cmd ) =
    let
        matidx_list =
            List.map (checkBounceMonsterList model.monster_list) model.ball_list

        mat_list =
            List.map Tuple.first matidx_list

        idx_list =
            List.map Tuple.second matidx_list

        elem_list =
            List.map (\ball -> ball.element) model.ball_list

        msg_list =
            List.map2 Hit idx_list elem_list

        nmonster_list =
            List.foldr updateMonster model.monster_list msg_list

        nscore =
            List.foldr (+) model.level_scores (List.map (getMonster_score model.monster_list) msg_list)

        elemball_list =
            List.map2 changeElement model.ball_list (List.map (findHitMonster model.monster_list) msg_list)

        nball_list =
            List.map2 newReflectedVelocity elemball_list mat_list
    in
    ( { model
        | ball_list = nball_list
        , monster_list = nmonster_list
        , level_scores = nscore
      }
    , cmd
    )


checkBounceMonsterList : List Monster -> Ball -> ( Mat, Int )
checkBounceMonsterList monster_list ball =
    let
        kickedMonsterList =
            List.filter (\monster -> checkBounceMonster ball monster /= identityMat) monster_list
    in
    case kickedMonsterList of
        [] ->
            ( identityMat, 0 )

        kickedMonster :: _ ->
            ( checkBounceMonster ball kickedMonster, kickedMonster.idx )


checkBounceMonster : Ball -> Monster -> Mat
checkBounceMonster ball monster =
    let
        ( x, y ) =
            monster.pos

        ( bx, by ) =
            ball.pos

        br =
            ball.radius

        r =
            monster.monster_radius
    in
    if (x - bx) ^ 2 + (y - by) ^ 2 <= (br + r) ^ 2 && innerVec ( x - bx, y - by ) ( ball.v_x, ball.v_y ) >= 0 && ball.state == Free then
        reflectionMat ( -(y - by), x - bx )

    else
        identityMat


bounceBoss : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
bounceBoss ( model, cmd ) =
    let
        oldBoss =
            model.boss

        ( hitBallList, otherBall ) =
            List.partition (\ball -> checkBounceBoss oldBoss ball /= identityMat) model.ball_list

        damage =
            List.sum (List.map (\ball -> elementMatch ball.element oldBoss.element) hitBallList)

        newBoss =
            { oldBoss | lives = oldBoss.lives - damage }

        nball_list =
            List.map (\ball -> { ball | element = oldBoss.element }) hitBallList ++ otherBall

        mat_list =
            List.map (checkBounceBoss oldBoss) nball_list

        nnball_list =
            List.map2 newReflectedVelocity nball_list mat_list
    in
    ( { model | ball_list = nnball_list, boss = newBoss }
    , cmd
    )


checkBounceBoss : Boss -> Ball -> Mat
checkBounceBoss boss ball =
    let
        ( x, y ) =
            boss.pos

        ( bx, by ) =
            ball.pos

        br =
            ball.radius

        r =
            boss.boss_radius
    in
    if (x - bx) ^ 2 + (y - by) ^ 2 <= (br + r) ^ 2 && innerVec ( x - bx, y - by ) ( ball.v_x, ball.v_y ) >= 0 then
        reflectionMat ( -(y - by), x - bx )

    else
        identityMat


updateTime : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
updateTime msg ( model, cmd ) =
    case msg of
        Tick elapse ->
            let
                oldboss =
                    model.boss

                newboss =
                    { oldboss | bosstime = oldboss.bosstime + elapse / 1000 }

                state =
                    model.state
            in
            if (state == Scene 0) && (model.time > 6.2) then
                updateScene model

            else
                ( { model | time = model.time + elapse / 1000, boss = newboss }, cmd )

        _ ->
            ( model, cmd )


checkFail : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
checkFail ( model, cmd ) =
    let
        ( belowBall, upBall ) =
            List.partition (\ball -> Tuple.second ball.pos >= 1100) model.ball_list
    in
    case belowBall |> List.head of
        Nothing ->
            ( model, cmd )

        Just _ ->
            ( { model
                | ball_list = upBall
              }
            , cmd
            )


checkBallNumber : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
checkBallNumber ( model, cmd ) =
    let
        elemNum =
            case model.level of
                1 ->
                    1

                2 ->
                    2

                _ ->
                    4
    in
    if List.length model.ball_list < model.ballnumber then
        checkBallNumber
            ( { model
                | ball_list = (generateBall model.paddle model.seed elemNum |> Tuple.first) :: model.ball_list
                , lives = model.lives - 1
                , seed = generateBall model.paddle model.seed elemNum |> Tuple.second
              }
            , cmd
            )

    else
        ( model, cmd )


checkEnd : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
checkEnd ( model, cmd ) =
    let
        bonus_score =
            Maybe.withDefault 0 (List.maximum [ model.lives, 0 ]) * 100
    in
    if model.lives <= 0 then
        ( { model
            | state = Gameover model.level
          }
        , cmd
        )

    else if (List.isEmpty model.monster_list && model.level < 5) || (model.boss.lives <= 0 && model.level == 5) then
        case model.state of
            Playing _ ->
                ( { model
                    | ball_list = List.map (\ball -> { ball | v_x = 0, v_y = 0 }) model.ball_list
                    , state = ClearLevel model.level
                    , scores = model.scores + model.level_scores + bonus_score + (model.level // 5) * 1000
                    , level_scores = 0
                    , monster_list = []
                  }
                , Cmd.batch [ cmd, Task.perform GetViewport getViewport ]
                )

            _ ->
                ( model, Cmd.none )

    else
        ( model, cmd )
