module Debounce exposing (..)

import Basics.Extra exposing (never)
import Process
import Task


type alias Model datatype =
    { data : datatype
    , sleepCount : Int
    }


init : datatype -> Model datatype
init val =
    { data = val, sleepCount = 0 }


type Msg datatype
    = Change datatype
    | Timeout Int


update : Msg datatype -> Model datatype -> ( Model datatype, Cmd (Msg datatype), Maybe datatype )
update msg model =
    case msg of
        Change data' ->
            let
                count' =
                    model.sleepCount + 1
            in
                ( { model | data = data', sleepCount = count' }
                , Process.sleep 500 |> Task.perform never (always (Timeout count'))
                , Nothing
                )

        Timeout count ->
            if count == model.sleepCount then
                ( { model | sleepCount = 0 }
                , Cmd.none
                , Just model.data
                )
            else
                ( model, Cmd.none, Nothing )
