module Main exposing (..)

import Feedback exposing (State(..), Submission(..))
import Html exposing (..)
import Html.Attributes exposing (..)


type alias Model =
    { feedback : Feedback.State
    , timesCancelled : Int
    , positiveSubmissions : Int
    , negativeReasonsGiven : List String
    }


init : ( Model, Cmd Msg )
init =
    ( { feedback = Feedback.init
      , timesCancelled = 0
      , positiveSubmissions = 0
      , negativeReasonsGiven = []
      }
    , Cmd.none
    )


type Msg
    = FeedbackUpdated Feedback.State
    | FeedbackSubmitted Feedback.Submission
    | FeedbackCancelled
    | ChooseReason Feedback.Reason
    | SelectNegative
    | SelectPositive


feedbackConfig : Feedback.State -> Feedback.Config Msg
feedbackConfig state =
    Feedback.config
        { id = "foo"
        , prompt = "Did you like the pandas?"
        , footnote = Just "Your feedback of the pandas will not be shared with the pandas"
        , chooseReason = ChooseReason
        , onSubmit = FeedbackSubmitted
        , onCancel = FeedbackCancelled
        , selectNegative = SelectNegative
        , selectPositive = SelectPositive
        , state = state
        , negativeReasons = [ "Too many pandas", "Not enough pandas" ]
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FeedbackUpdated feedbackState ->
            ( { model | feedback = feedbackState }, Cmd.none )

        FeedbackSubmitted submission ->
            case submission of
                Positive ->
                    ( { model
                        | positiveSubmissions = model.positiveSubmissions + 1
                        , feedback = Feedback.init
                      }
                    , Cmd.none
                    )

                Negative reason ->
                    ( { model
                        | negativeReasonsGiven = reason :: model.negativeReasonsGiven
                        , feedback = Feedback.init
                      }
                    , Cmd.none
                    )

        FeedbackCancelled ->
            ( { model | timesCancelled = model.timesCancelled + 1, feedback = Feedback.init }, Cmd.none )

        ChooseReason r ->
            ( { model | feedback = Feedback.NegativeSelected r }
            , Cmd.none
            )

        SelectNegative ->
            ( { model
                | feedback =
                    case model.feedback of
                        PositiveSelected ->
                            SelectingNegative

                        SelectingNegative ->
                            SelectingNegative

                        NegativeSelected reason ->
                            NegativeSelected reason

                        Unselected ->
                            SelectingNegative
              }
            , Cmd.none
            )

        SelectPositive ->
            ( { model | feedback = PositiveSelected }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Feedback.view (feedbackConfig model.feedback)
        , div [ class "positive-submit-count" ] [ text <| toString model.positiveSubmissions ++ " loved  pandas" ]
        , div [ class "negative-submit-count" ]
            [ List.length model.negativeReasonsGiven
                |> toString
                |> text
            ]
        , ul [ class "negative-reasons-given" ] (List.map (\reason -> li [] [ text reason ]) model.negativeReasonsGiven)
        , div [ class "cancel-count" ] [ text <| toString model.timesCancelled ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
