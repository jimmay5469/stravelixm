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

type Msg = ClickActivity Activity | HoverActivity Activity | UnhoverActivity Activity | ZoomFit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ZoomFit ->
            (model, resetZoom ())
        ClickActivity activity ->
            (model, zoomActivity activity)
        UnhoverActivity activity ->
            case model.hoveredActivity of
                Nothing -> (model, Cmd.none)
                Just hoveredActivity ->
                    case hoveredActivity == activity of
                        False -> (model, Cmd.none)
                        True -> ({ model | hoveredActivity = Nothing }, resetHighlight ())
        HoverActivity activity ->
            ({ model | hoveredActivity = Just activity }, highlightActivity activity)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ clickActivity ClickActivity
        , unhoverActivity UnhoverActivity
        , hoverActivity HoverActivity
        ]


-- PORTS

port loadMap : List Activity -> Cmd msg
port resetHighlight : () -> Cmd msg
port highlightActivity : Activity -> Cmd msg
port resetZoom : () -> Cmd msg
port zoomActivity : Activity -> Cmd msg

port clickActivity : (Activity -> msg) -> Sub msg
port unhoverActivity : (Activity -> msg) -> Sub msg
port hoverActivity : (Activity -> msg) -> Sub msg


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "row"
        , style
            [ ("position", "fixed")
            , ("top", "0")
            , ("bottom", "0")
            , ("left", "0")
            , ("right", "0")
            ]
        ]
    [ div [ class "col-xs-5 col-sm-4 col-md-3 col-lg-2", style [("overflow", "scroll")] ]
        [ div [ class "row center-xs" ]
            [ div [ class "col-xs-11 col-md-10" ]
                [ div [ class "row start-xs" ]
                    [ div [ class "col-xs-12"]
                        [ viewHeader model
                        , button
                            [ style [("cursor", "pointer")]
                            , onClick (ZoomFit)
                            ] [ text "Zoom Fit" ]
                        , ul [] (List.map (viewActivity model) model.activities)
                        ]
                    ]
                ]
            ]
        ]
    , div [ class "col-xs-7 col-sm-8 col-md-9 col-lg-10", style [("padding-left", "0")] ]
        [ div [ id "map", style [("width", "100%") , ("height", "100%")] ] []
        , div [ id "miniMap", style [("width", "400px"), ("height", "300px")] ] []
        ]
    ]

viewHeader : Model -> Html Msg
viewHeader model =
    div []
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
            , onMouseOut (UnhoverActivity activity)
            ]
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
