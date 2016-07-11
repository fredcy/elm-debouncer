module Main exposing (main)

import Debounce
import Html
import Html.App
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
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model "" "" (Debounce.init ""), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Input str ->
            let
                ( debouncer', cmd, _ ) =
                    Debounce.update (Debounce.Change str) model.debouncer
            in
                { model | rawInput = str, debouncer = debouncer' }
                    ! [ Cmd.map DebouncerMsg cmd ]

        DebouncerMsg dmsg ->
            let
                ( debouncer', cmd, debouncedMaybe ) =
                    Debounce.update dmsg model.debouncer

                debouncedInput' =
                    Maybe.withDefault model.debouncedInput debouncedMaybe
            in
                { model | debouncer = debouncer', debouncedInput = debouncedInput' }
                    ! [ Cmd.map DebouncerMsg cmd ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h3 [] [ Html.text "Input here" ]
        , Html.input [ Html.onInput Input ] []
        , Html.h3 [] [ Html.text "Debounced value" ]
        , Html.div [] [ Html.text model.debouncedInput ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
