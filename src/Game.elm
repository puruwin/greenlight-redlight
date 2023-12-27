module Game exposing (..)

import Html exposing (Html, div, p, img, text)
import Browser
import Html.Attributes exposing (class, src, width)
import Html.Events exposing (onClick)
import Time
import Process
import Task


-- Model
type alias Model = 
  { username : String
  , score : Int
  , highScore : Int
  , remainingLives : Int
  , greenLight : Bool
  }

initialModel : Model
initialModel =
  { username = "puruwin"
  , score = 0
  , highScore = 0
  , remainingLives = 3
  , greenLight = True
  }

-- Update
type Msg
  = ClickedStep
  | SwitchLights


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ClickedStep ->
      ( { model | score = model.score + 1 }, Cmd.none )
    SwitchLights ->
      ( model, changeTrafficLights ( { model | greenLight = not model.greenLight } ) )

-- View
view : Model -> Html Msg
view model =
  div [] [
    div [ class "header" ]
    [ div [ class "welcome" ]
      [ p [ class "welcome-text" ] [
        text "Welcome to the game!"
        ]
      ]
      , div [ class "logout" ] [
        div [ class "logout-btn" ] []
      ]
    ]
  , div [ class "wrapper" ] [
    p [ class "highscore" ] [
      text "Highscore: "
    ]
    , img [ src (
            if model.greenLight then
                "/assets/img/green-light.png"
            else 
                "/assets/img/red-light.png"
            ), width 100 ] []
    , p [ class "current-score" ] [
      text ("Score: " ++ String.fromInt model.score)
    ]
    , div [ class "steps" ] [
        div [ class "left-step-btn", onClick ClickedStep ] []
      , div [ class "right-step-btn", onClick ClickedStep ] []
    ]
  ]
  ]


changeTrafficLights : Model -> Cmd Msg
changeTrafficLights model =
    if model.greenLight then
        Process.sleep 3000
        |> Task.perform ( \_ -> SwitchLights )
    else
        Process.sleep 6000 
        |> Task.perform ( \_ -> SwitchLights )

init : () -> (Model, Cmd Msg)
init _ =
  ( initialModel, changeTrafficLights initialModel )

-- Main
main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }
