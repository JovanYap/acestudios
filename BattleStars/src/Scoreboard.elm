module Scoreboard exposing (findHitMonster, getMonster_score)

import Data exposing (Monster)
import Messages exposing (Msg(..))
import MyElement exposing (elementMatch)



-- Scoreboard system done by Jovan


getMonster_score : List Monster -> Msg -> Int
getMonster_score list_monster msg =
    case msg of
        Hit _ ball_element ->
            case findHitMonster list_monster msg of
                Just monster ->
                    monster.monster_score
                        * ((monster.element |> elementMatch ball_element)
                            |> bonusScore
                          )

                Nothing ->
                    0

        _ ->
            0


bonusScore : Int -> Int
bonusScore eff =
    case eff of
        1 ->
            1

        2 ->
            2

        4 ->
            5

        _ ->
            0


findHitMonster : List Monster -> Msg -> Maybe Monster
findHitMonster monster_list msg =
    case msg of
        Hit k _ ->
            Tuple.first (List.partition (\{ idx } -> idx == k) monster_list)
                |> List.head

        _ ->
            Nothing
