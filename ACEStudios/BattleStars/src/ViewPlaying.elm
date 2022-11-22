module ViewPlaying exposing (viewPlaying)

{- This file contains all the helper functions needed in the major game states -}

import Color exposing (getColorful, getcolor)
import Data exposing (Ball, Boss, Monster, monsterheight, monsterwidth, pixelHeight, pixelWidth)
import Debug exposing (toString)
import Html exposing (Html, div, text)
import Html.Attributes as HtmlAttr exposing (style)
import Messages exposing (Msg(..))
import Model exposing (Model)
import MyElement exposing (element2ColorString, element2String)
import Svg exposing (Svg, stop)
import Svg.Attributes as SvgAttr



{- view the playing scene -}


viewPlaying : Model -> Html Msg
viewPlaying model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > pixelWidth / pixelHeight then
                Basics.min 1 (h / pixelHeight)

            else
                Basics.min 1 (w / pixelWidth)
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat pixelWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat pixelHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - pixelWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - pixelHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , HtmlAttr.style "background" "url('./assets/image/background.png')"
        ]
        [ Svg.svg
            [ SvgAttr.width "100%"
            , SvgAttr.height "100%"
            ]
            -- draw monsters
            ([ viewBase model

             -- , viewLife model
             ]
                ++ viewLives model
                ++ List.map viewMonsters model.monster_list
                ++ List.concat (List.map viewCover model.monster_list)
                ++ List.concat (List.map viewBall (List.reverse model.ball_list))
                ++ viewBoss model.boss
                ++ viewBossCover model.boss
                ++ [ viewPaddle model ]
            )
        , viewScore model
        ]



---------
--viewMonsters
---------


viewMonsters : Monster -> Svg Msg
viewMonsters monster =
    let
        ( x, y ) =
            monster.pos
    in
    Svg.image
        [ SvgAttr.width (toString monsterwidth)
        , SvgAttr.height (toString monsterheight)
        , SvgAttr.x (toString (x - monsterwidth / 2))
        , SvgAttr.y (toString (y - monsterheight / 2))
        , SvgAttr.preserveAspectRatio "none"
        , SvgAttr.xlinkHref ("./assets/image/" ++ element2String monster.element ++ "Monster.png")
        ]
        []


viewCover : Monster -> List (Svg msg)
viewCover monster =
    let
        color =
            element2ColorString monster.element

        live =
            if monster.monster_lives >= 0 then
                monster.monster_lives

            else
                0
    in
    [ Svg.radialGradient
        [ SvgAttr.id ("myRadial" ++ color ++ toString live) ]
        [ stop
            [ SvgAttr.offset "40%"
            , SvgAttr.stopOpacity "0%"
            ]
            []
        , stop
            [ SvgAttr.offset "95%"
            , SvgAttr.stopColor color
            , SvgAttr.stopOpacity (toString (0.2 * toFloat live))
            ]
            []
        ]
    , Svg.circle
        [ SvgAttr.cx (toString (Tuple.first monster.pos))
        , SvgAttr.cy (toString (Tuple.second monster.pos))
        , SvgAttr.r (toString (monster.monster_radius - 8))
        , SvgAttr.fill ("url('#myRadial" ++ color ++ toString live ++ "')")
        ]
        []
    ]


viewBoss : Boss -> List (Svg Msg)
viewBoss boss =
    let
        ( x, y ) =
            boss.pos
    in
    if boss.lives <= 0 && boss.lives > -10 then
        []

    else
        [ Svg.image
            [ SvgAttr.width "1000"
            , SvgAttr.height "500"
            , SvgAttr.x (toString (x - 500))
            , SvgAttr.y (toString (y + 700))
            , SvgAttr.preserveAspectRatio "none"
            , SvgAttr.xlinkHref "./assets/image/bossMonster.png"
            ]
            []
        ]


viewBossCover : Boss -> List (Svg Msg)
viewBossCover boss =
    let
        color =
            element2ColorString boss.element

        live =
            if boss.lives >= 0 then
                boss.lives

            else if boss.lives <= -10 then
                100

            else
                0
    in
    if boss.lives <= 0 && boss.lives > -10 then
        []

    else
        [ Svg.radialGradient
            [ SvgAttr.id ("myRadial" ++ color ++ toString live) ]
            [ stop
                [ SvgAttr.offset "30%"
                , SvgAttr.stopOpacity "0%"
                ]
                []
            , stop
                [ SvgAttr.offset "97%"
                , SvgAttr.stopColor color
                , SvgAttr.stopOpacity (toString (0.008 * toFloat live))
                ]
                []
            ]
        , Svg.circle
            [ SvgAttr.cx (toString (Tuple.first boss.pos))
            , SvgAttr.cy (toString (Tuple.second boss.pos))
            , SvgAttr.r (toString (boss.boss_radius - 8))
            , SvgAttr.fill ("url('#myRadial" ++ color ++ toString live ++ "')")
            ]
            []
        ]



----------
--view Paddle, score, ball, lives and base
----------


viewPaddle : Model -> Svg Msg
viewPaddle model =
    Svg.image
        [ SvgAttr.width (toString model.paddle.width)
        , SvgAttr.height (toString model.paddle.height)
        , SvgAttr.x (toString (Tuple.first model.paddle.pos))
        , SvgAttr.y (toString (Tuple.second model.paddle.pos))
        , SvgAttr.preserveAspectRatio "xMidYMid slice"
        , SvgAttr.xlinkHref "./assets/image/ufo.png"
        ]
        []


viewBall : Ball -> List (Svg Msg)
viewBall ball =
    let
        color =
            element2ColorString ball.element
    in
    [ Svg.radialGradient
        [ SvgAttr.id ("myBall" ++ color) ]
        [ stop
            [ SvgAttr.offset "0.1%"
            , SvgAttr.stopColor "white"
            , SvgAttr.stopOpacity "95%"
            ]
            []
        , stop
            [ SvgAttr.offset "50%"
            , SvgAttr.stopColor color
            , SvgAttr.stopOpacity "50%"
            ]
            []
        , stop
            [ SvgAttr.offset "100%"
            , SvgAttr.stopColor color
            , SvgAttr.stopOpacity "100%"
            ]
            []
        ]
    , Svg.circle
        [ SvgAttr.cx (toString (Tuple.first ball.pos))
        , SvgAttr.cy (toString (Tuple.second ball.pos))
        , SvgAttr.r (toString ball.radius)
        , SvgAttr.fill ("url('#myBall" ++ color ++ "')")
        ]
        []
    ]


viewScore : Model -> Html Msg
viewScore model =
    div
        [ style "top" "20px"
        , style "color" (getcolor (getColorful model.time))
        , style "font-family" "Helvetica, Arial, sans-serif"
        , style "font-size" "60px"
        , style "font-weight" "bold" -- Thickness of text
        , style "left" "1020px"
        , style "text-align" "center"
        , style "line-height" "60px"
        , style "position" "absolute"
        ]
        [ text (toString (model.scores + model.level_scores)) ]


viewLife : Int -> Svg Msg
viewLife x =
    -- draw cities using rectangles later
    Svg.image
        [ SvgAttr.width "180px"
        , SvgAttr.height "100px"
        , SvgAttr.x (toString x)
        , SvgAttr.y "1070px"
        , SvgAttr.preserveAspectRatio "xMidYMid"
        , SvgAttr.xlinkHref "./assets/image/city.png"
        ]
        []


viewLives : Model -> List (Svg Msg)
viewLives model =
    List.range 1 model.lives
        |> List.map (\x -> (x - 1) * 205)
        |> List.map viewLife


viewBase : Model -> Svg Msg
viewBase model =
    Svg.rect
        [ SvgAttr.fill (getcolor (getColorful model.time))
        , SvgAttr.width (toString pixelWidth ++ "px")
        , SvgAttr.height "30px"
        , SvgAttr.y "1170px"
        , SvgAttr.x "0px"
        ]
        []
