port module Game exposing (..)

import Browser
import Html exposing (Html, div, p, img, text, button)
import Html.Attributes exposing (class, src, width)
import Html.Events exposing (onClick)
import Http exposing (Error(..))
import Element exposing (el, centerX, centerY, layout)
import Firestore exposing (Error(..))
import Firestore.Config as Config
import Firestore.Decode as FSDecode
import Firestore.Encode as FSEncode
import Firestore.Query as Query
import Json.Decode as Decode
import RemoteData exposing (RemoteData(..), WebData)
import Result.Extra as Result
import Random exposing (int)
import Time exposing (Posix)
import Process
import Task
import Firestore.Query as Query
import Firestore.Query as Query


---- Ports ----


port signIn : () -> Cmd msg


---- Model ----


type alias Score =
  Int


type alias User =
  { email : String
  , uid : String
  }


type alias Stats =
  { highScore : Score }


type alias ErrorData =
  { code : String
  , message : String
  , credential : String
  }



type alias Model = 
  { firestore : Firestore.Firestore
  , stats : WebData (Firestore.Document Stats)
  , currentScore : Score
  , highscore : Score
  , user : WebData User
  , greenLight : Bool
  , randomSeed : Int
  , lastStep : Maybe Step
  }


type alias Flags =
  ( String, String )


initialState : Firestore.Firestore -> Model
initialState firestore =
  { firestore = firestore
  , stats = NotAsked
  , currentScore = 0
  , highscore = 0
  , user = NotAsked
  , greenLight = False
  , randomSeed = 0
  , lastStep = Nothing
  }

init : Flags -> ( Model, Cmd Msg )
init ( apiKey, project ) =
  ( initialState
    ( Firestore.init <| Config.new { apiKey = apiKey, project = project })
  , Task.perform SetTime Time.now
  )


---- Update ----


type Msg
  = LogIn
  | LoggedInData (Result Decode.Error User)
  | ClickedStep Step
  | SwitchLights
  | NewSeed Int
  | SetTime Posix


type Step
  = LeftStep
  | RightStep


fetchStats model =
  ( { model | stats = Loading }
  , case model.user of
      Success { uid } ->
        let
          query : Query.Query
          query =
            Query.new
              |> Query.collection "stats"
              |> Query.where_ "uid" Query.Equal uid
        in
        model.firestore
          |> Firestore.root
          |> Firestore.collection "user"
          |> Firestore.document uid
          |> Firestore.build
          |> Result.toTask
          |> Task.andThen (Firestore.runQuery decoder query)
          |> Task.attempt FetchStats
      
      _ ->
        Cmd.none
  )


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LogIn ->
      ( model, signIn () )

    LoggedInData (Ok user) ->
      case model.stats of
        NotAsked ->
          fetchHighscore { model | user = Success user }
        
        _ ->
          ( model, Cmd.none )

    ClickedStep step ->
      if model.greenLight then
        let
          newScore =
            case model.lastStep of
              Just lastStep ->
                if lastStep /= step then
                  model.currentScore + 1

                else
                  model.currentScore - 1

              Nothing ->
                model.currentScore + 1
        in
        ( { model | currentScore = newScore, lastStep = Just step }, Cmd.none )
      else
        ( { model | currentScore = 0 }, Cmd.none )

    SwitchLights ->
      let
        updatedModel = { model | greenLight = not model.greenLight }
      in
        ( updatedModel, changeTrafficLights updatedModel )

    NewSeed seed ->
      ( { model | randomSeed = seed }, Cmd.none )


---- View ----
view : Model -> Html Msg
view ({ stats } as model) =
  case stats of
    NotAsked ->
      div [ class "wrapper" ] [
        button [ onClick (Just LogIn) ] [ text "Sign in with Google" ]
      ]

    Failure message ->
      div [ class "wrapper" ] [ text (httpErrorToString message) ]

    Loading ->
      div [ class "wrapper" ] [ text "Loading..." ]

    Success _ ->
      viewGame model



viewGame : Model -> Html Msg
viewGame model =
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
      text ("Score: " ++ String.fromInt model.currentScore)
    ]
    , div [ class "steps" ] [
        div [ class "left-step-btn", onClick (ClickedStep LeftStep) ] []
      , div [ class "right-step-btn", onClick (ClickedStep RightStep) ] []
    ]
  ]
  ]

changeTrafficLights : Model -> Cmd Msg
changeTrafficLights model =
    if model.greenLight then
        let
            randomNumber = round ((max (10000 - (toFloat model.currentScore * 100)) 2000) + (toFloat model.randomSeed))
        in
        Process.sleep (toFloat randomNumber)
        |> Task.perform ( \_ -> SwitchLights )
    else
        Process.sleep 3000 
        |> Task.perform ( \_ -> SwitchLights )


decoder : FSDecode.Decoder Stats
decoder =
    FSDecode.document Stats
        |> FSDecode.required "highscore" FSDecode.string
        |> FSDecode.required "uid" FSDecode.string
        |> FSDecode.required "date" FSDecode.timestamp


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        BadUrl url ->
            "The URL " ++ url ++ " was invalid"

        Timeout ->
            "Unable to reach the server, try again"

        NetworkError ->
            "Unable to reach the server, check your network connection"

        BadStatus code ->
            "The server responded with BadStatus " ++ String.fromInt code

        BadBody body ->
            "The server responded with BadBody: " ++ body


newSeed : Cmd Msg
newSeed =
    Random.generate NewSeed (Random.int -750 750)


---- Main ----
main : Program () Model Msg
main =
  Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }
