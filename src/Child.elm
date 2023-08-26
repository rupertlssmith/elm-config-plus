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
update config msg model =
    case msg of
        Whatever ->
            updateContextAndFetchStuff model
                |> config.onUpdate

        LogOut ->
            doSomeLogOutThings model
                |> config.onLogout
                |> U2.withCmd (config.changeModal LoggingOutModal)


updateContextAndFetchStuff : Model -> ( Model, Cmd msg )
updateContextAndFetchStuff model =
    U2.pure model


doSomeLogOutThings : Model -> ( Model, Cmd msg )
doSomeLogOutThings model =
    U2.pure model
