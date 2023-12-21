module Game exposing (..)

import Html exposing (Html, div, text)
import Browser


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
  div [] [ text "Hello, Elm!" ]

-- Main
main : Program () Model Msg
main =
  Browser.sandbox
    { init = init
    , update = update
    , view = view
    }
