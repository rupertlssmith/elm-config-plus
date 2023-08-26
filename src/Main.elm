module Main exposing (..)

{-| The idea: "Invert the control, pass in a record of continuations and let the child
update choose which branch to take without ever needing to know what’s going on."

Thanks to @hayleigh on Elm slack for coming up with this one.

-}

import Update2 as U2


type alias Model =
    { context : Context }


type ParentMsg
    = ContextMsg Msg


defaultActions : Model -> Config ParentMsg Model
defaultActions model =
    { toMsg = ContextMsg
    , changeModal = always Cmd.none
    , resetModal = Cmd.none
    , onUpdate =
        U2.map (\context -> { model | context = context })
            >> U2.andThen afterNormalUpdate
    , onLogout =
        U2.map (\context -> { model | context = context })
            >> U2.andThen afterLogout
    }


parentUpdate : ParentMsg -> Model -> ( Model, Cmd ParentMsg )
parentUpdate msg model =
    case msg of
        ContextMsg contextMsg ->
            update (defaultActions model) contextMsg model.context


afterNormalUpdate : model -> ( model, Cmd msg )
afterNormalUpdate model =
    U2.pure model


afterLogout : model -> ( model, Cmd msg )
afterLogout model =
    U2.pure model


type alias Config msg model =
    { toMsg : Msg -> msg

    -- Side effects this module can ask for but does not implement itself.
    , changeModal : Modal -> Cmd msg
    , resetModal : Cmd msg

    -- The continuation stuff
    , onUpdate : ( Context, Cmd msg ) -> ( model, Cmd msg )
    , onLogout : ( Context, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = Whatever
    | LogOut


type alias Context =
    {}


type Modal
    = LoggingOutModal


update : Config msg model -> Msg -> Context -> ( model, Cmd msg )
update config msg model =
    case msg of
        Whatever ->
            updateContextAndFetchStuff model
                |> config.onUpdate

        LogOut ->
            doSomeLogOutThings model
                |> config.onLogout
                |> U2.withCmd (config.changeModal LoggingOutModal)


updateContextAndFetchStuff : Context -> ( Context, Cmd msg )
updateContextAndFetchStuff model =
    U2.pure model


doSomeLogOutThings : Context -> ( Context, Cmd msg )
doSomeLogOutThings model =
    U2.pure model
