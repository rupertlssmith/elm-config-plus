module Parent exposing (Model, Msg, init, subscriptions, update, view)

{-| The idea: "Invert the control, pass in a record of continuations and let the child
update choose which branch to take without ever needing to know what’s going on."

Thanks to @hayleigh on Elm slack for coming up with this one.

-}

import Auth
import Browser
import Child
import Config exposing (config)
import Html
import Html.Styled
import Update2 as U2


type alias Model =
    { auth : Auth.Model
    , child : Child.Model
    }


type Msg
    = ChildMsg Child.Msg
    | AuthMsg Auth.Msg


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { auth = Auth.init, child = Child.init }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


authProtocol : Model -> Auth.Protocol Auth.Model Msg Model
authProtocol model =
    { toMsg = AuthMsg
    , onUpdate =
        U2.map (\auth -> { model | auth = auth })
    , onLoginOk =
        U2.map (\auth -> { model | auth = auth })
    , onLoginFail =
        U2.map (\auth -> { model | auth = auth })
    }


childProtocol : Model -> Child.Protocol Child.Model Msg Model
childProtocol model =
    { toMsg = ChildMsg
    , onUpdate = U2.map (\child -> { model | child = child })
    , onLogin =
        \cred ->
            U2.map (\child -> { model | child = child })
                >> U2.andThen (processLogin cred)
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChildMsg innerMsg ->
            Child.update (childProtocol model) innerMsg model.child

        AuthMsg innerMsg ->
            Auth.update (authProtocol model) innerMsg model.auth


processLogin : Auth.Credentials -> Model -> ( Model, Cmd Msg )
processLogin cred model =
    Auth.tryLogin (authProtocol model) cred model.auth


view : Model -> Browser.Document Msg
view model =
    { title = "Protocol Pattern Example"
    , body =
        [ Child.view model.child
            |> Html.Styled.toUnstyled
            |> Html.map ChildMsg
        ]
    }
