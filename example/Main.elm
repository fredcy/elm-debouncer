module Main exposing (main)

import Debounce
import Html
import Html.App
import Html.Events as Html


type alias Model =
    { rawInput : String
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
    ( Model "" (Debounce.init 500 ""), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Input str ->
            let
                ( debouncer', cmd ) =
                    Debounce.update (Debounce.Change str) model.debouncer
            in
                { model | rawInput = str, debouncer = debouncer' }
                    ! [ Cmd.map DebouncerMsg cmd ]

        DebouncerMsg dmsg ->
            let
                ( debouncer', cmd ) =
                    Debounce.update dmsg model.debouncer
            in
                { model | debouncer = debouncer' }
                    ! [ Cmd.map DebouncerMsg cmd ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.h3 [] [ Html.text "Input here" ]
        , Html.input [ Html.onInput Input ] []
        , Html.h3 [] [ Html.text "Debounced value" ]
        , Html.div [] [ Html.text model.debouncer.settled ]
        , Html.h3 [] [ Html.text "Model" ]
        , Html.div [] [ Html.text <| toString model ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
