module Router exposing (..)

import Json.Encode exposing (Value)
import Update2 as U2


type alias Protocol submodel msg model =
    { toMsg : Msg -> msg
    , onUpdate : Value -> ( submodel, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = Receive Value


type alias Model =
    {}


update : Protocol Model msg model -> Msg -> Model -> ( model, Cmd msg )
update protocol msg model =
    case msg of
        Receive val ->
            U2.pure model
                |> protocol.onUpdate val
