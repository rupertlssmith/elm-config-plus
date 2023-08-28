module Parent exposing (Model, Msg, init, subscriptions, update, view)

{-| The idea: "Invert the control, pass in a record of continuations and let the child
update choose which branch to take without ever needing to know what’s going on."

Thanks to @hayleigh on Elm slack for coming up with this one.

-}

import Auth
import Browser
import Html
import Html.Styled
import LoginPrompt
import Update2 as U2


type alias Model =
    { auth : Auth.Model
    , child : LoginPrompt.Model
    }


type Msg
    = LoginPromptMsg LoginPrompt.Msg
    | AuthMsg Auth.Msg


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { auth = Auth.init, child = LoginPrompt.init }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


authProtocol : Model -> Auth.Protocol Auth.Model Msg Model
authProtocol model =
    let
        setAuth auth =
            { model | auth = auth }
    in
    { toMsg = AuthMsg
    , onUpdate = U2.map setAuth
    , onLoginOk = U2.map setAuth
    , onLoginFail = U2.map setAuth >> U2.andThen (init () |> always)
    }


childProtocol : Model -> LoginPrompt.Protocol LoginPrompt.Model Msg Model
childProtocol model =
    let
        setChild child =
            { model | child = child }
    in
    { toMsg = LoginPromptMsg
    , onUpdate = U2.map setChild
    , onLogin = \cred -> U2.map setChild >> U2.andThen (processLogin cred)
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoginPromptMsg innerMsg ->
            LoginPrompt.update (childProtocol model) innerMsg model.child

        AuthMsg innerMsg ->
            Auth.update (authProtocol model) innerMsg model.auth


processLogin : Auth.Credentials -> Model -> ( Model, Cmd Msg )
processLogin cred model =
    Auth.tryLogin (authProtocol model) cred model.auth


view : Model -> Browser.Document Msg
view model =
    { title = "Protocol Pattern Example"
    , body =
        [ LoginPrompt.view model.child
            |> Html.Styled.toUnstyled
            |> Html.map LoginPromptMsg
        ]
    }
