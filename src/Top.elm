module Top exposing (main)

import Browser
import Parent


main : Program () Parent.Model Parent.Msg
main =
    Browser.document
        { init = Parent.init
        , update = Parent.update
        , subscriptions = Parent.subscriptions
        , view = Parent.view
        }
