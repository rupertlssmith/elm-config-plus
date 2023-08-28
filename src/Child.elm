module Child exposing (Model, Msg, Protocol, update)

import Auth exposing (Credentials)
import Update2 as U2


type alias Protocol submodel msg model =
    { toMsg : Msg -> msg

    -- Where to continue after an update.
    , onUpdate : ( submodel, Cmd msg ) -> ( model, Cmd msg )
    , onLogin : Credentials -> ( submodel, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = LogIn Credentials


type alias Model a =
    a


update : Protocol (Model a) msg model -> Msg -> Model a -> ( model, Cmd msg )
update actions msg model =
    case msg of
        LogIn cred ->
            U2.pure model
                |> actions.onLogin cred
