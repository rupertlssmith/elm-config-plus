module LoginPrompt exposing (Model, Msg, Protocol, init, update, view)

import Auth exposing (Credentials)
import Config exposing (config)
import Css
import Css.Global
import Grid
import Html.Styled as Html exposing (Html, div, form, h4, img, label, span, styled, text, toUnstyled)
import Html.Styled.Attributes as HA exposing (for, name, src)
import Html.Styled.Events as HE exposing (onClick, onInput)
import Responsive
import Style
import Styles exposing (lg, md, sm, xl)
import TheSett.Buttons as Buttons
import TheSett.Cards as Cards
import TheSett.Laf as Laf exposing (devices, fonts, responsiveMeta, wrapper)
import TheSett.Textfield as Textfield
import Update2 as U2


type alias Protocol submodel msg model =
    { toMsg : Msg -> msg

    -- Where to continue after an update.
    , onUpdate : ( submodel, Cmd msg ) -> ( model, Cmd msg )
    , onLogin : Credentials -> ( submodel, Cmd msg ) -> ( model, Cmd msg )
    }


type Msg
    = LafMsg Laf.Msg
    | LogIn
    | LogOut
    | RespondWithNewPassword
    | TryAgain
    | Refresh
    | UpdateUsername String
    | UpdatePassword String
    | UpdatePasswordVerificiation String


type alias Model =
    { laf : Laf.Model
    , username : String
    , password : String
    , passwordVerify : String
    }


init : Model
init =
    { laf = Laf.init
    , username = ""
    , password = ""
    , passwordVerify = ""
    }


update : Protocol Model msg model -> Msg -> Model -> ( model, Cmd msg )
update actions msg model =
    case msg of
        LogIn ->
            U2.pure model
                |> actions.onLogin { username = model.username, password = model.password }

        UpdateUsername str ->
            ( { model | username = str }, Cmd.none )
                |> actions.onUpdate

        UpdatePassword str ->
            ( { model | password = str }, Cmd.none )
                |> actions.onUpdate

        _ ->
            U2.pure model
                |> actions.onUpdate



-- View


{-| Top level view function.
-}
view : Model -> Html Msg
view model =
    let
        innerView =
            [ responsiveMeta
            , fonts
            , Laf.style devices
            , Css.Global.global Style.global
            , loginView model
            ]
    in
    div [] innerView



-- initializedView : InitializedModel -> Html.Styled.Html Msg
-- initializedView model =
--     case model.session of
--         AuthAPI.LoggedOut ->
--             loginView model
--         AuthAPI.Failed NotAuthorized ->
--             notPermittedView model
--         AuthAPI.Failed PasswordResetRequired ->
--             passwordResetRequiredView model
--         AuthAPI.Failed _ ->
--             errorView "Error"
--         AuthAPI.LoggedIn state ->
--             authenticatedView model state
--         AuthAPI.Challenged Auth.NewPasswordRequired ->
--             requiresNewPasswordView model


loginView : { a | laf : Laf.Model, username : String, password : String } -> Html Msg
loginView model =
    framing <|
        [ card "images/data_center-large.png"
            "Log In"
            [ form []
                [ Textfield.text
                    LafMsg
                    [ 1 ]
                    model.laf
                    [ Textfield.value model.username ]
                    [ onInput UpdateUsername
                    ]
                    [ text "Username" ]
                    devices
                , Textfield.password
                    LafMsg
                    [ 2 ]
                    model.laf
                    [ Textfield.value model.password
                    ]
                    [ onInput UpdatePassword
                    ]
                    [ text "Password" ]
                    devices
                ]
            ]
            [ Buttons.button [] [ onClick LogIn ] [ text "Log In" ] devices
            ]
            devices
        ]



-- notPermittedView : { a | laf : Laf.Model, username : String, password : String } -> Html.Styled.Html Msg
-- notPermittedView model =
--     framing <|
--         [ card "images/data_center-large.png"
--             "Not Authorized"
--             [ form []
--                 [ Textfield.text
--                     LafMsg
--                     [ 1 ]
--                     model.laf
--                     [ Textfield.disabled
--                     , Textfield.value model.username
--                     ]
--                     [ onInput UpdateUsername
--                     ]
--                     [ text "Username" ]
--                     devices
--                 , Textfield.password
--                     LafMsg
--                     [ 2 ]
--                     model.laf
--                     [ Textfield.disabled
--                     , Textfield.value model.password
--                     ]
--                     [ onInput UpdatePassword
--                     ]
--                     [ text "Password" ]
--                     devices
--                 ]
--             ]
--             [ Buttons.button [] [ onClick TryAgain ] [ text "Try Again" ] devices ]
--             devices
--         ]
-- passwordResetRequiredView : { a | laf : Laf.Model, username : String, password : String } -> Html.Styled.Html Msg
-- passwordResetRequiredView model =
--     framing <|
--         [ card "images/data_center-large.png"
--             "Password Reset Required"
--             [ form []
--                 [ Textfield.text
--                     LafMsg
--                     [ 1 ]
--                     model.laf
--                     []
--                     [ onInput UpdateUsername
--                     ]
--                     [ text "Authorization Code" ]
--                     devices
--                 ]
--             ]
--             [ Buttons.button [] [ onClick TryAgain ] [ text "Try Again" ] devices ]
--             devices
--         ]
-- authenticatedView : { a | username : String, auth : Auth.Model } -> { b | scopes : List String, subject : String } -> Html.Styled.Html Msg
-- authenticatedView model user =
--     let
--         maybeAWSCredentials =
--             Auth.api.getAWSCredentials model.auth
--         credentialsView =
--             case maybeAWSCredentials of
--                 Just creds ->
--                     [ Html.Styled.li []
--                         (text "With AWS access credentials."
--                             :: Html.Styled.br [] []
--                             :: []
--                         )
--                     ]
--                 Nothing ->
--                     []
--     in
--     framing <|
--         [ card "images/data_center-large.png"
--             "Authenticated"
--             [ Html.Styled.ul []
--                 (List.append
--                     [ Html.Styled.li []
--                         [ text "Logged In As:"
--                         , Html.Styled.br [] []
--                         , text model.username
--                         ]
--                     , Html.Styled.li []
--                         [ text "With Id:"
--                         , Html.Styled.br [] []
--                         , text user.subject
--                         ]
--                     , Html.Styled.li []
--                         (text "With Permissions:"
--                             :: Html.Styled.br [] []
--                             :: permissionsToChips user.scopes
--                         )
--                     ]
--                     credentialsView
--                 )
--             ]
--             [ Buttons.button [] [ onClick LogOut ] [ text "Log Out" ] devices
--             , Buttons.button [] [ onClick Refresh ] [ text "Refresh" ] devices
--             ]
--             devices
--         ]
-- requiresNewPasswordView : { a | laf : Laf.Model, password : String, passwordVerify : String } -> Html.Styled.Html Msg
-- requiresNewPasswordView model =
--     framing <|
--         [ card "images/data_center-large.png"
--             "New Password Required"
--             [ form []
--                 [ Textfield.password
--                     LafMsg
--                     [ 1 ]
--                     model.laf
--                     [ Textfield.value model.password ]
--                     [ onInput UpdatePassword
--                     ]
--                     [ text "Password" ]
--                     devices
--                 , Textfield.password
--                     LafMsg
--                     [ 2 ]
--                     model.laf
--                     [ Textfield.value model.passwordVerify
--                     ]
--                     [ onInput UpdatePasswordVerificiation
--                     ]
--                     [ text "Password Confirmation" ]
--                     devices
--                 ]
--             ]
--             [ Buttons.button [] [ onClick RespondWithNewPassword ] [ text "Set Password" ] devices
--             ]
--             devices
--         ]


framing : List (Html Msg) -> Html Msg
framing innerHtml =
    styled div
        [ Responsive.deviceStyle devices
            (\device -> Css.marginTop <| Responsive.rhythmPx 3 device)
        ]
        []
        [ Grid.grid
            [ sm [ Grid.columns 12 ] ]
            []
            [ Grid.row
                [ sm [ Grid.center ] ]
                []
                [ Grid.col
                    []
                    []
                    innerHtml
                ]
            ]
            devices
        ]


card :
    String
    -> String
    -> List (Html Msg)
    -> List (Html Msg)
    -> Responsive.ResponsiveStyle
    -> Html Msg
card imageUrl title cardBody controls devices =
    Cards.card
        [ sm
            [ Styles.styles
                [ Css.maxWidth <| Css.vw 100
                , Css.minWidth <| Css.px 310
                , Css.backgroundColor <| Style.colors.paperWhite
                ]
            ]
        , md
            [ Styles.styles
                [ Css.maxWidth <| Css.px 420
                , Css.minWidth <| Css.px 400
                , Css.backgroundColor <| Style.colors.paperWhite
                ]
            ]
        ]
        []
        [ Cards.image
            [ Styles.height 6
            , sm [ Cards.src imageUrl ]
            ]
            []
            [ styled div
                [ Css.position Css.relative
                , Css.height <| Css.pct 100
                ]
                []
                []
            ]
        , Cards.title title
        , Cards.body cardBody
        , Cards.controls controls
        ]
        devices



-- permissionsToChips : List String -> List (Html.Styled.Html Msg)
-- permissionsToChips permissions =
--     List.map
--         (\permission ->
--             Html.Styled.span [ Html.Styled.Attributes.class "mdl-chip mdl-chip__text" ]
--                 [ text permission ]
--         )
--         permissions
