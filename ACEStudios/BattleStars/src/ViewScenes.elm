module ViewScenes exposing (viewClearLevel, viewGameover, viewOtherScene, viewScene0, viewScene1, viewStarting)

{- This file contains all the scenes for the game -}

import Color exposing (getColorful, getcolor)
import Debug exposing (toString)
import Html exposing (Html, button, div, text)
import Html.Attributes as HtmlAttr exposing (style)
import Html.Events exposing (onClick)
import Messages exposing (..)
import Model exposing (Model)


sceneWidth : Float
sceneWidth =
    2135.231317


sceneHeight : Float
sceneHeight =
    1200


numList : Int -> List Float
numList num =
    List.map toFloat (List.range 1 num)


wordsPosSize : Int -> Float -> List ( ( Float, Float ), Int )
wordsPosSize num x =
    List.map (\y -> ( ( x, y ), 35 )) (List.map (\yInt -> 250 + 75 * yInt) (numList num))


viewOtherScene : Int -> Model -> Html Msg
viewOtherScene n model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > sceneWidth / sceneHeight then
                Basics.min 1 (h / sceneHeight)

            else
                Basics.min 1 (w / sceneWidth)

        htmlMsg =
            matchScene n model
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat sceneWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat sceneHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - sceneWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - sceneHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , HtmlAttr.style "background" ("url('./assets/image/scene.png')" ++ " no-repeat fixed " ++ " 0px " ++ " 0px / " ++ "2135.231317px " ++ " 1200px")
        ]
        htmlMsg


matchScene : Int -> Model -> List (Html Msg)
matchScene n model =
    let
        x =
            761.9107343

        x_ =
            700
    in
    case n of
        7 ->
            List.map4 (helperScene1 model.time)
                (List.repeat 4 "dodgerblue" ++ List.repeat 2 "white")
                (numList (List.length (wordsList 7)))
                (wordsList 7)
                (wordsPosSize (List.length (wordsList 7)) x_)

        k ->
            List.map3 (helperScene1 model.time "white")
                (numList (List.length (wordsList k)))
                (wordsList k)
                (wordsPosSize (List.length (wordsList k)) x)


logoWidth : Float
logoWidth =
    523.2558


logoHeight : Float
logoHeight =
    600


determineOpct : Float -> Float
determineOpct t =
    if t <= 6 then
        sin (t * pi / 6) * 2 / 1.732

    else
        0


viewScene0 : Model -> Html Msg
viewScene0 model =
    let
        ( w, h ) =
            model.size

        t =
            model.time

        r =
            if w / h > logoWidth / logoHeight then
                Basics.min 1 (h / logoHeight)

            else
                Basics.min 1 (w / logoWidth)
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat logoWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat logoHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - logoWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - logoHeight * r) / 2) ++ "px")
        , HtmlAttr.style "opacity" (determineOpct t |> String.fromFloat)
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , ("url('./assets/image/ace.png')" ++ " no-repeat fixed " ++ " 0px " ++ " 0px / " ++ " 523.2558px " ++ " 600px")
            |> HtmlAttr.style "background"
        ]
        []


viewScene1 : Model -> Html Msg
viewScene1 model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > sceneWidth / sceneHeight then
                Basics.min 1 (h / sceneHeight)

            else
                Basics.min 1 (w / sceneWidth)

        x =
            100
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat sceneWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat sceneHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - sceneWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - sceneHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        ]
        [ ( ( x, 100 ), 30 )
            |> helperScene1 model.time "dodgerblue" 1 "Zandalore, the only space colony that has mastered immortality,"
        , ( ( x, 180 ), 30 )
            |> helperScene1 model.time "dodgerblue" 2 "has been living in peace for the past few centuries."
        , ( ( x, 260 ), 30 )
            |> helperScene1 model.time "dodgerblue" 3 "But one day, the elemental monsters attack Zandalore"
        , ( ( x, 340 ), 30 )
            |> helperScene1 model.time "dodgerblue" 4 "and kill millions of Zandalorians to steal the secret to immortality."
        , ( ( x, 420 ), 30 )
            |> helperScene1 model.time "dodgerblue" 5 "General, you are our only hope to save Zandalore!"
        , ( ( x, 500 ), 30 )
            |> helperScene1 model.time "white" 6 "Click Enter to continue"
        ]


startWidth : Float
startWidth =
    1200


startHeight : Float
startHeight =
    1200


viewStarting : Model -> Html Msg
viewStarting model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > startWidth / startHeight then
                Basics.min 1 (h / startHeight)

            else
                Basics.min 1 (w / startWidth)
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat startWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat startHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - startWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - startHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , ("url('./assets/image/Start.png')"
            ++ " no-repeat fixed "
            ++ " 0px "
            ++ " 0px / "
            ++ (toString startWidth ++ "px " ++ (toString startHeight ++ "px"))
          )
            |> HtmlAttr.style "background"
        ]
        [ renderStartButton
        , div [ HtmlAttr.style "z-index" "99999999" ]
            [ Html.audio
                [ HtmlAttr.autoplay True
                , HtmlAttr.loop True
                , HtmlAttr.controls True
                , HtmlAttr.src "./assets/audio/gamePlay.ogg"
                , HtmlAttr.preload "True"
                , HtmlAttr.id "gamePlay"
                ]
                []
            ]
        ]


clearWidth : Float
clearWidth =
    6400 / 3


cleatHeight : Float
cleatHeight =
    1200


viewClearLevel : Model -> Html Msg
viewClearLevel model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > clearWidth / cleatHeight then
                Basics.min 1 (h / cleatHeight)

            else
                Basics.min 1 (w / clearWidth)
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat clearWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat cleatHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - clearWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - cleatHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , HtmlAttr.style "background" "url('./assets/image/background.png')"
        ]
        [ nextSceneButton
        , ( ( 6400 * (2490 - 1385) / 6 / 2490, 300 ), 100 )
            |> helperScene1 model.time (getcolor (getColorful model.time)) 1 "MISSION ACCOMPLISHED"
        , ( ( 6400 * (2490 - 883) / 6 / 2490, 450 ), 100 )
            |> helperScene1 model.time (getcolor (getColorful model.time)) 1 ("Level " ++ toString model.level ++ " cleared")
        , ( ( 6400 * (2490 - 700) / 6 / 2490, 600 ), 100 )
            |> helperScene1 model.time (getcolor (getColorful model.time)) 2 ("Score: " ++ toString model.scores)
        ]


viewGameover : Model -> Html Msg
viewGameover model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > clearWidth / cleatHeight then
                Basics.min 1 (h / cleatHeight)

            else
                Basics.min 1 (w / clearWidth)
    in
    div
        [ HtmlAttr.style "width" (String.fromFloat clearWidth ++ "px")
        , HtmlAttr.style "height" (String.fromFloat cleatHeight ++ "px")
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "left" (String.fromFloat ((w - clearWidth * r) / 2) ++ "px")
        , HtmlAttr.style "top" (String.fromFloat ((h - cleatHeight * r) / 2) ++ "px")
        , HtmlAttr.style "transform-origin" "0 0"
        , HtmlAttr.style "transform" ("scale(" ++ String.fromFloat r ++ ")")
        , HtmlAttr.style "background" "url('./assets/image/background.png')"
        ]
        [ newGameButton
        , ( ( 649.7978, 450 ), 100 )
            |> helperScene1 model.time (getcolor (getColorful model.time)) 1 "MISSION FAILED"
        ]


newGameButton : Html Msg
newGameButton =
    button
        [ style "background" "#34495f"
        , style "top" "790px"
        , style "color" "white"
        , style "display" "block"
        , style "font-size" "18px"
        , style "font-weight" "500"
        , style "height" "80px"
        , style "left" "986.6667px"
        , style "position" "absolute"
        , style "width" "160px"
        , onClick Restart
        ]
        [ text "Try Again" ]


renderStartButton : Html Msg
renderStartButton =
    button
        [ style "opacity" "0"
        , style "top" "974.4px" -- to be changed
        , style "left" "496.8px" -- to be changed
        , style "cursor" "pointer"
        , style "display" "block"
        , style "height" "136.8px"
        , style "line-height" "60px"
        , style "padding" "0"
        , style "position" "absolute"
        , style "width" "218.4px"
        , onClick Start
        ]
        []


nextSceneButton : Html Msg
nextSceneButton =
    button
        [ style "background" "#34495f"
        , style "top" "790px"
        , style "color" "white"
        , style "font-size" "18px"
        , style "font-weight" "500"
        , style "height" "80px"
        , style "left" "986.6667px"
        , style "line-height" "60px"
        , style "outline" "none"
        , style "position" "absolute"
        , style "width" "160px"
        , onClick NextScene
        ]
        [ text "Next Level" ]


helperScene1 : Float -> String -> Float -> String -> ( ( Float, Float ), Int ) -> Html Msg
helperScene1 modeltime color time string ( ( x, y ), font ) =
    div
        [ HtmlAttr.style "opacity" (toString (modeltime - time))
        , HtmlAttr.style "left" (toString x ++ "px")
        , HtmlAttr.style "top" (toString y ++ "px")
        , style "font-weight" "bold"
        , HtmlAttr.style "color" color
        , HtmlAttr.style "position" "absolute"
        , HtmlAttr.style "font-size" (toString font ++ "px")
        ]
        [ text string ]


wordsList : Int -> List String
wordsList k =
    case k of
        2 ->
            [ "Gameplay: Water is more effective against fire"
            , "There are 2 different monsters: fire and water monster."
            , "Boss elemental monster functions as a border here."
            , "Bullet changes element after coming in contact with monster."
            , "Water bullets deal more damage against fire monsters."
            , "All the best General! Destroy the evil elemental monsters!"
            , "Click S during the game to skip the level and SPACE to fire"
            , "Click Enter to continue"
            ]

        3 ->
            [ "General!! The monsters have penetrated into our defences!"
            , "Gameplay: Boss monster changes element periodically"
            , "Monsters are moving down"
            , "2 lives will be deducted when monsters are too low."
            , "See you on the other side General!"
            , "Click S during the game to skip the level and SPACE to fire"
            , "Click Enter to continue"
            ]

        4 ->
            [ "General!! There is another wave of monsters attacking!"
            , "Gameplay: Water>Fire>Nature>Earth>Water"
            , "Monsters will move down even faster"
            , "Higher scores awarded for more effective kills"
            , "General, you are our only hope to save Zandalore!"
            , "Click S during the game to skip the level and SPACE to fire"
            , "Click Enter to continue"
            ]

        5 ->
            [ "General!! The monsters seem like they are retreating!"
            , "Gameplay: 2 balls present"
            , "Choose when you want to launch ball with SPACE"
            , "Monsters will be moving around"
            , "Do not be complacent, the war isn't over yet!"
            , "Click S during the game to skip the level and SPACE to fire"
            , "Click Enter to continue"
            ]

        6 ->
            [ "Bad news!! The elemental boss monster is attacking us!"
            , "Gameplay: defeat the boss!"
            , "Boss will spawn smaller elemental monsters"
            , "Remember, strategy is key to winning."
            , "General, this is your last chance to exterminate them!"
            , "Click S during the game to skip the level and SPACE to fire"
            , "Click Enter to continue"
            ]

        _ ->
            [ "Zandalore has won the war and defeated the vicious elemental monsters!"
            , "Undeniably, destroying the monsters was no easy feat. "
            , "General, I thank you for accomplishing this key mission."
            , "You have saved the world and justice has prevailed!"
            , "You have completed Boss Level!"
            , "Click Enter to go back to the Homepage"
            ]
