module Main exposing (..)

{-| invert the control, pass in a record of continuations and let the child update choose which branch to take
without ever needing to know what’s going on

So for context we have a Context module that is mostly a model/update (no view) that acts as a the brain of
our app. It stores all the data from the api and all that good stuff, manages requests etc.
The main Auth route module is what handles the context updating and stuff, and afterwards it goes on to do
some other work, so to simplify we have something like this in the auth update:

    ContextMsg contextMsg ->
      Context.update contextMsg ...
        |> Data.Update.map (\context -> { model | context = context })
        |> Data.Update.andThen doSomeOtherStuff
        |> Data.Update.andThen andSomeMoreStuff

-}


type Msg
    = Whatever
    | LogOut


type alias Model =
    {}



-- (Data.Update is just some wrappers around the (model, Cmd msg) tuple for nicer piping)
-- The context can initiate a log out, at which point the doSomeOtherStuff and andSomeMoreStuff dont need to
-- be called anymore, and so we want some way for the context to say “dont do any extra stuff, we’re
-- logging out”.
-- I’m sure you can think of the usual suspects, but with continuations we might do this:
{-
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
-- and then inside Context.update it would look like
-- so the signature of Context.update changes from:
{- Context.update : Msg -> Model -> ( Model, Cmd Msg ) -}
-- to


type alias ConfigV1 parentMsg parentModel =
    { onNormalUpdate : ( Model, Cmd Msg ) -> ( parentModel, Cmd parentMsg )
    , onLogout : ( Model, Cmd Msg ) -> ( parentModel, Cmd parentMsg )
    }


type alias ConfigV2 msg model =
    { toMsg : Msg -> msg
    , changeModal : Modal -> Cmd msg
    , resetModal : Cmd msg

    -- The continuation stuff
    , onNormalUpdate : Update msg Context -> Update msg model
    , onLogout : Update msg Context -> Update msg model
    }



{- Context.Update :
   Msg
   -> Model
   -> K parentMsg parentModel
   -> ( parentModel, parentMsg )
-}
-- Eh really? I've used Config pattern with msg , so you can use these from within view
-- in that case then it’s totally composable as normal then


type Modal
    = LoggingOutModal


type alias Context =
    {}



{-
   Context.Update : Msg -> Model -> Config msg model -> Update msg model
-}
-- (here Update is just a type alias for ( model, Cmd msg ))
-- you’d do:


updatev1 : Msg -> Model -> ConfigV1 parentMsg parentModel -> ( parentModel, Cmd parentMsg )
updatev1 msg model config =
    case msg of
        Whatever ->
            updateContextAndFetchStuff model
                |> config.onNormalUpdate

        LogOut ->
            doSomeLogOutThings model
                |> config.onLogout


updatev2 : Msg -> Model -> ConfigV2 parentMsg parentModel -> ( parentModel, Cmd parentMsg )
updatev2 msg model config =
    case msg of
        Whatever ->
            updateContextAndFetchStuff model
                |> config.onNormalUpdate

        LogOut ->
            doSomeLogOutThings model
                |> config.onLogout
                |> withCmd (config.changeModal LoggingOutModal)


updateContextAndFetchStuff =
    Debug.todo ""


doSomeLogOutThings =
    Debug.todo ""


type alias Update msg model =
    ( model, Cmd msg )


withCmd =
    Debug.todo "withCmd"
