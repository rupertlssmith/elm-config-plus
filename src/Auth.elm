module Auth exposing (Credentials, Model, Msg, Protocol, tryLogin, update)

import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Update2 as U2


type alias Protocol submodel msg model =
    { toMsg : Msg -> msg

    -- Where to continue after an update.
    , onUpdate : ( submodel, Cmd msg ) -> ( model, Cmd msg )
    , onLoginOk : ( submodel, Cmd msg ) -> ( model, Cmd msg )
    , onLoginFail : ( submodel, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = LoginResponse (Result Error User)


type alias User =
    { username : String
    , accessKey : String
    }


andMap =
    Decode.map2 (|>)


userDecoder : Decoder User
userDecoder =
    Decode.succeed User
        |> andMap (Decode.field "username" Decode.string)
        |> andMap (Decode.field "accesskey" Decode.string)


type alias Credentials =
    { username : String
    , password : String
    }


encodeCredentials : Credentials -> Value
encodeCredentials cred =
    [ ( "username", Encode.string cred.username )
    , ( "password", Encode.string cred.password )
    ]
        |> Encode.object


type Model
    = NotAuthed
    | LoggedIn User


update : Protocol Model msg model -> Msg -> Model -> ( model, Cmd msg )
update actions msg _ =
    case msg of
        LoginResponse (Ok user) ->
            U2.pure (LoggedIn user)
                |> actions.onLoginOk

        LoginResponse (Err _) ->
            U2.pure NotAuthed
                |> actions.onLoginFail


tryLogin : Protocol Model msg model -> Credentials -> Model -> ( model, Cmd msg )
tryLogin actions cred model =
    ( model
    , Http.post
        { url = "https://service.com/login"
        , body = encodeCredentials cred |> Http.jsonBody
        , expect = Http.expectJson LoginResponse userDecoder
        }
        |> Cmd.map actions.toMsg
    )
        |> actions.onUpdate
