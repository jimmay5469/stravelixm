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
    { loginLink: String
    , logoutLink: String
    , athlete: Maybe Athlete
    , activities: List Activity
    , hoveredActivity: Maybe Activity }

type alias Activity =
    { id: Int
    , name: String
    , athlete: Athlete
    , map: Map
    }

type alias Athlete =
    { id: Int
    , lastname: Maybe String
    , firstname: Maybe String
    }

type alias Map =
    { summaryPolyline: Maybe String
    }


-- INIT

type alias Flags =
    { loginLink: String
    , logoutLink: String
    , athlete: Maybe Athlete
    , activities: List Activity
    }

init : Flags -> (Model, Cmd Msg)
init flags =
    (Model flags.loginLink flags.logoutLink flags.athlete flags.activities Nothing, loadMap flags.activities)


-- UPDATE

type Msg = ClickActivity Activity | HoverActivity Activity | UnhoverActivity () | ZoomFit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ClickActivity activity ->
            (model, zoomActivity activity)
        HoverActivity activity ->
            ({ model | hoveredActivity = Just activity }, highlightActivity activity)
        UnhoverActivity na ->
            ({ model | hoveredActivity = Nothing }, resetHighlight ())
        ZoomFit ->
            (model, resetZoom ())


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ clickActivity ClickActivity
        , hoverActivity HoverActivity
        , unhoverActivity UnhoverActivity
        ]


-- PORTS

port loadMap : List Activity -> Cmd msg
port highlightActivity : Activity -> Cmd msg
port resetHighlight : () -> Cmd msg
port zoomActivity : Activity -> Cmd msg
port resetZoom : () -> Cmd msg

port clickActivity : (Activity -> msg) -> Sub msg
port hoverActivity : (Activity -> msg) -> Sub msg
port unhoverActivity : (() -> msg) -> Sub msg


-- VIEW

view : Model -> Html Msg
view model =
    div []
    [ viewHeader model
    , ul
        [ style [ ("position", "fixed")
                , ("top", "110px")
                , ("bottom", "20px")
                , ("left", "20px")
                , ("width", "310px")
                , ("overflow-x", "hidden")
                , ("overflow-y", "auto")
                ]
        ] (List.map (viewActivity model) model.activities)
    , button
        [ onClick (ZoomFit)
        , style [ ("position", "fixed")
                , ("top", "115px")
                , ("right", "25px")
                , ("z-index", "1")
                ]
        ] [ text "Zoom Fit" ]
    , div [ id "miniMap", style [("width", "400px"), ("height", "300px")] ] []
    , div
        [ id "mapContainer"
        , style [ ("position", "fixed")
                , ("top", "110px")
                , ("bottom", "20px")
                , ("left", "350px")
                , ("right", "20px")
                ]
        ] [ div
            [ id "map"
            , style [ ("width", "100%")
                    , ("height", "100%")
                    ]
            ] []
        ]
    ]

viewHeader : Model -> Html Msg
viewHeader model =
    div [ style [ ("position", "fixed")
                , ("top", "0px")
                , ("left", "0px")
                ]
        ]
    [ h1 [][ text "Stravelixm" ]
    , viewGreeting model
    ]

viewGreeting : Model -> Html Msg
viewGreeting model =
    case model.athlete of
        Nothing -> a [ href model.loginLink ][ text "Login" ]
        Just athlete ->
            case athlete.firstname of
                Nothing -> a [ href model.logoutLink ][ text "Logout" ]
                Just firstname ->
                    span []
                      [ text ("Hi " ++ firstname ++ "! (")
                      , a [ href model.logoutLink ][ text "logout" ]
                      , text ")"
                      ]

viewActivity : Model -> Activity -> Html Msg
viewActivity model activity =
    li []
        [ a [ style (activityStyle model activity)
            , onClick (ClickActivity activity)
            , onMouseOver (HoverActivity activity)
            , onMouseOut (UnhoverActivity ())]
            [ text activity.name ]
        , (viewActivityAthlete activity.athlete)
        ]

viewActivityAthlete : Athlete -> Html Msg
viewActivityAthlete athlete =
    case (athlete.firstname, athlete.lastname) of
        (Just firstname, Just lastname) -> text (" (" ++ firstname ++ " " ++ lastname ++ ")")
        (_, _) -> text ""

activityStyle : Model -> Activity -> List (String, String)
activityStyle model activity =
    if isHovered model activity then
        [("cursor", "pointer"), ("text-decoration", "underline"), ("color", "red")]
    else
        [("cursor", "pointer")]

isHovered : Model -> Activity -> Bool
isHovered model activity =
    case model.hoveredActivity of
        Just hoveredActivity -> hoveredActivity == activity
        Nothing -> False
