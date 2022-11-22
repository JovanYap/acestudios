module View exposing (view)

{- This file contains the view function for all the major game states -}
-- import Html.Events exposing (onClick)

import Html exposing (Html, div)
import Html.Attributes as HtmlAttr
import Messages exposing (Msg)
import Model exposing (Model, State(..))
import ViewPlaying exposing (..)
import ViewScenes exposing (..)



-- View, ViewScenes created by Jovan


view : Model -> Html Msg
view model =
    let
        viewAll =
            case model.state of
                Starting ->
                    viewStarting model

                Playing _ ->
                    viewPlaying model

                ClearLevel _ ->
                    viewClearLevel model

                Scene 0 ->
                    viewScene0 model

                Scene 1 ->
                    viewScene1 model

                Scene a ->
                    viewOtherScene a model

                Gameover _ ->
                    viewGameover model
    in
    div
        [ HtmlAttr.style "width" "100%"
        , HtmlAttr.style "height" "100%"
        , HtmlAttr.style "position" "fixed"
        , HtmlAttr.style "left" "0"
        , HtmlAttr.style "top" "0"
        , HtmlAttr.style "background" "black"
        ]
        [ viewAll
        ]
