module Main exposing (..)

{-| The idea: "Invert the control, pass in a record of continuations and let the child update choose
which branch to take without ever needing to know what’s going on."

Thanks for @hayleigh on Elm slack for coming up with this one.

-}


type Msg
    = Whatever
    | LogOut


type alias Model =
    {}



{- This is in the parent update calling the child one:

   ContextMsg contextMsg ->
     Context.update contextMsg ...
       { onNormalUpdate =
           Data.Update.map (\context -> { model | context = context })
             >> Data.Update.andThen wibble
             >> Data.Update.andThen wobble
       , onLogout =
           Data.Update.map (\context -> { model | context = context })
       }
-}


type alias Config msg model =
    { toMsg : Msg -> msg
    , changeModal : Modal -> Cmd msg
    , resetModal : Cmd msg

    -- The continuation stuff
    , onUpdate : ( Context, Cmd msg ) -> ( model, Cmd msg )
    , onLogout : ( Context, Cmd msg ) -> ( model, Cmd msg )
    }


type Modal
    = LoggingOutModal


type alias Context =
    {}


update : Msg -> Model -> Config parentMsg parentModel -> ( parentModel, Cmd parentMsg )
update msg model config =
    case msg of
        Whatever ->
            updateContextAndFetchStuff model
                |> config.onUpdate

        LogOut ->
            doSomeLogOutThings model
                |> config.onLogout
                |> withCmd (config.changeModal LoggingOutModal)


updateContextAndFetchStuff model =
    Debug.todo ""


doSomeLogOutThings model =
    Debug.todo ""


withCmd : Cmd msg -> ( model, Cmd msg ) -> ( model, Cmd msg )
withCmd cmd ( model, cmds ) =
    ( model, Cmd.batch [ cmd, cmds ] )
