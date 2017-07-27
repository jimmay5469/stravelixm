module Main exposing (..)
import Html exposing (Html, text, ul, li)

main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL
type alias Model =
    { activities: List String }


-- INIT
type alias Flags =
    { activities: List String }

init : Flags -> (Model, Cmd Msg)
init flags =
    ({ activities = flags.activities }
    , Cmd.none)


-- UPDATE

type Msg = Submit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (model, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


-- VIEW
view : Model -> Html Msg
view model =
    ul [] (List.map viewActivity model.activities)

viewActivity : String -> Html Msg
viewActivity activity =
    li [] [ text activity ]
