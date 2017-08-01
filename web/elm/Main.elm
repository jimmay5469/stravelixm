port module Main exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)

main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


-- MODEL
type alias Model =
    { activities: List Activity }

type alias Activity =
    { id: Int
    , name: String
    }


-- INIT
type alias Flags =
    { activities: List Activity }

init : Flags -> (Model, Cmd Msg)
init flags =
    ({ activities = flags.activities }
    , loadMap ())


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
    div []
    [ ul [] (List.map viewActivity model.activities)
    , div
        [ id "map"
        , style [("height", "500px")]
        ] []
    ]

viewActivity : Activity -> Html Msg
viewActivity activity =
    li []
        [ a [ href ("https://www.strava.com/activities/" ++ (toString activity.id)) ]
            [ text activity.name ]
        ]


port loadMap : () -> Cmd msg
