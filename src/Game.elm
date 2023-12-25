module Game exposing (..)

import Html exposing (Html, div, p, img, text)
import Browser
import Html.Attributes exposing (class, src, width)


-- Model
type alias Model = 
  { username : String
  , score : Int
  , highScore : Int
  , remainingLives : Int
  }

init : Model
init =
  { username = "puruwin"
  , score = 0
  , highScore = 0
  , remainingLives = 3
  }

-- Update
type Msg
  = NoOp

update : Msg -> Model -> Model
update msg model =
  case msg of
    NoOp ->
      model

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
    , img [ src "/assets/img/red-light.png", width 100 ] []
    , p [ class "current-score" ] [
      text "Score: "
    ]
    , div [ class "steps" ] [
        div [ class "left-step-btn" ] []
      , div [ class "right-step-btn" ] []
    ]
  ]
  ]

-- Main
main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }
