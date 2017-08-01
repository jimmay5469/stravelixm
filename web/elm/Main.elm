port module Main exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

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
    , map: Map
    }

type alias Map =
    { summary_polyline: Maybe String
    }


-- INIT
type alias Flags =
    { activities: List Activity }

init : Flags -> (Model, Cmd Msg)
init flags =
    ({ activities = flags.activities }
    , loadMap flags.activities)


-- UPDATE

type Msg = ZoomActivity Activity | ResetZoom

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ZoomActivity activity ->
            (model, zoomActivity activity)
        ResetZoom ->
            (model, resetZoom ())


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
        [ a [ href ("https://www.strava.com/activities/" ++ (toString activity.id))
            , onMouseOver (ZoomActivity activity)
            , onMouseOut ResetZoom]
            [ text activity.name ]
        ]


port loadMap : List Activity -> Cmd msg
port zoomActivity : Activity -> Cmd msg
port resetZoom : () -> Cmd msg
