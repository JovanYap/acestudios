module Paddle exposing (Paddle, movePaddle)

import Messages exposing (Dir(..))


type alias Paddle =
    { pos : ( Float, Float )
    , moveLeft : Bool
    , moveRight : Bool
    , latestDir : Dir
    , height : Float
    , width : Float
    , speed : Float
    , move_range : Float
    }


movePaddle : Paddle -> Float -> Paddle
movePaddle paddle dt =
    case ( paddle.moveLeft, paddle.moveRight, paddle.latestDir ) of
        ( True, False, _ ) ->
            if isLegalMovePaddle paddle Left then
                { paddle | pos = newPaddlePos paddle.pos Left (paddle.speed * dt) }

            else
                paddle

        ( False, True, _ ) ->
            if isLegalMovePaddle paddle Right then
                { paddle | pos = newPaddlePos paddle.pos Right (paddle.speed * dt) }

            else
                paddle

        ( True, True, dir ) ->
            if isLegalMovePaddle paddle dir then
                { paddle | pos = newPaddlePos paddle.pos dir (paddle.speed * dt) }

            else
                paddle

        _ ->
            paddle



--wyj


isLegalMovePaddle : Paddle -> Dir -> Bool
isLegalMovePaddle { pos, width, move_range } dir =
    case dir of
        Left ->
            if Tuple.first pos <= 0 then
                False

            else
                True

        Right ->
            if Tuple.first pos + width >= move_range then
                --the right bound of the game screen
                False

            else
                True

newPaddlePos : ( Float, Float ) -> Dir -> Float -> ( Float, Float )
newPaddlePos ( px, py ) dir ds =
    case dir of
        Left ->
            ( px - ds, py )

        Right ->
            ( px + ds, py )
