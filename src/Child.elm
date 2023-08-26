module Child exposing (Actions, Model, Msg, update)

import Update2 as U2


type Modal
    = LoggingOutModal


type alias Actions msg model =
    { toMsg : Msg -> msg

    -- Side effects this module can ask for but does not implement itself.
    , changeModal : Modal -> Cmd msg
    , resetModal : Cmd msg

    -- Where to continue after an update.
    , onUpdate : ( Model, Cmd msg ) -> ( model, Cmd msg )
    , onLogout : ( Model, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = Whatever
    | LogOut


type alias Model =
    {}


update : Actions msg model -> Msg -> Model -> ( model, Cmd msg )
update actions msg model =
    case msg of
        Whatever ->
            updateContextAndFetchStuff actions model
                |> actions.onUpdate

        LogOut ->
            doSomeLogOutThings actions model
                |> actions.onLogout
                |> U2.withCmd (actions.changeModal LoggingOutModal)


updateContextAndFetchStuff : Actions msg model -> Model -> ( Model, Cmd msg )
updateContextAndFetchStuff _ model =
    U2.pure model


doSomeLogOutThings : Actions msg model -> Model -> ( Model, Cmd msg )
doSomeLogOutThings _ model =
    U2.pure model
