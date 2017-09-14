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
    , previewedActivity: Maybe Activity
    , selectedActivity: Maybe Activity }

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
    ( Model flags.loginLink flags.logoutLink flags.athlete flags.activities Nothing Nothing
    , loadMap flags.activities
    )


-- UPDATE

type Msg = StartActivityPreview Activity | StopActivityPreview () | SelectActivity Activity | DeselectActivity | Reset

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        StartActivityPreview activity ->
            ({ model | previewedActivity = Just activity }, highlightActivity activity)
        StopActivityPreview _ ->
            ({ model | previewedActivity = Nothing }, resetHighlight ())
        SelectActivity activity ->
            ({ model | selectedActivity = Just activity }, zoomActivity activity)
        DeselectActivity ->
            ({ model | selectedActivity = Nothing }, Cmd.none)
        Reset ->
            ({ model | selectedActivity = Nothing, previewedActivity = Nothing }, resetZoom ())


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ unhoverActivity StopActivityPreview
        , hoverActivity StartActivityPreview
        , clickActivity SelectActivity
        ]


-- PORTS

port loadMap : List Activity -> Cmd msg
port resetHighlight : () -> Cmd msg
port highlightActivity : Activity -> Cmd msg
port resetZoom : () -> Cmd msg
port zoomActivity : Activity -> Cmd msg

port unhoverActivity : (() -> msg) -> Sub msg
port hoverActivity : (Activity -> msg) -> Sub msg
port clickActivity : (Activity -> msg) -> Sub msg


-- VIEW

view : Model -> Html Msg
view model =
    div [ id "elmContainer", class "row" ]
        [ div [ id "sideBarContainer", class "col-xs-5 col-sm-4 col-md-3 col-lg-2" ]
            [ div [ class "row center-xs" ]
                [ div [ class "col-xs-11 col-md-10" ]
                    [ div [ class "row start-xs" ]
                        [ div [ class "col-xs-12"]
                            [ viewHeader model
                            , button [ onClick (Reset) ] [ text "Zoom Fit" ]
                            , ul [] (List.map (viewActivity model) model.activities)
                            ]
                        ]
                    ]
                ]
            ]
        , div [ id "mapContainer", class "col-xs-7 col-sm-8 col-md-9 col-lg-10" ]
            [ div [ id "map" ] []
            , div [ id "miniMap" ] []
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
        [ a [ classList [ ("previewedActivity", (isPreviewingActivity model activity)) ]
            , onMouseOver (StartActivityPreview activity)
            , onMouseOut (StopActivityPreview ())
            , onClick (SelectActivity activity)
            ]
            [ text activity.name ]
        , (viewActivityAthlete activity.athlete)
        ]

viewActivityAthlete : Athlete -> Html Msg
viewActivityAthlete athlete =
    case (athlete.firstname, athlete.lastname) of
        (Just firstname, Just lastname) -> text (" (" ++ firstname ++ " " ++ lastname ++ ")")
        (_, _) -> text ""

isPreviewingActivity : Model -> Activity -> Bool
isPreviewingActivity model activity =
    case model.previewedActivity of
        Just previewedActivity -> previewedActivity == activity
        Nothing -> False
