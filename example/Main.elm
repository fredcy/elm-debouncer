module Main exposing (main)

import Debounce
import Html
import Html.Events as Html


type alias Model =
    { rawInput : String
    , debouncedInput : String
    , debouncer : Debounce.Model String
    }


type Msg
    = Input String
    | DebouncerMsg (Debounce.Msg String)


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" (Debounce.init 500 ""), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Input str ->
            -- save raw input and then inform debouncer of change
            { model | rawInput = str }
                |> updateDebouncer (Debounce.Change str)

        DebouncerMsg dmsg ->
            updateDebouncer dmsg model


{-| Update main model given a Debounce.Msg. This is standard component-update
stuff, plus checking the additional return value from Debounce.update for
notification that the value has settled.
-}
updateDebouncer : Debounce.Msg String -> Model -> ( Model, Cmd Msg )
updateDebouncer dMsg model =
    let
        ( debouncer_, cmd, settledMaybe ) =
            Debounce.update dMsg model.debouncer

        debouncedInput_ =
            settledMaybe |> Maybe.withDefault model.debouncedInput
    in
        { model | debouncer = debouncer_, debouncedInput = debouncedInput_ }
            ! [ Cmd.map DebouncerMsg cmd ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h3 [] [ Html.text "Input here" ]
        , Html.input [ Html.onInput Input ] []
        , Html.h3 [] [ Html.text "Debounced value" ]
        , Html.div [] [ Html.text model.debouncedInput ]
        ]
