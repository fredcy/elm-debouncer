module Debounce exposing (Model, Msg(Change), init, update, settled)

import Basics.Extra exposing (never)
import Process
import Task
import Time exposing (Time)

{-|
This provides a component that can "debounce" a changing value.
-}


type alias Model datatype =
    { data : datatype
    , settled : datatype
    , sleepCount : Int
    , settleTime : Time
    }


{-| Initialize the debouncer with the initial settled value and the time to wait
for changing values to settle.
-}
init : Time -> datatype -> Model datatype
init settleTime val =
    { data = val, settled = val, sleepCount = 0, settleTime = settleTime }


type Msg datatype
    = Change datatype
    | Timeout Int


{-| Access the settled value.
-}
settled : Model datatype -> datatype
settled model =
    model.settled


{-| Update the debouncer as a typical TEA component.
-}
update : Msg datatype -> Model datatype -> ( Model datatype, Cmd (Msg datatype) )
update msg model =
    case msg of
        Change data' ->
            let
                count' =
                    model.sleepCount + 1
            in
                { model | data = data', sleepCount = count' }
                    ! [ Process.sleep model.settleTime |> Task.perform never (always (Timeout count')) ]

        Timeout count ->
            if count == model.sleepCount then
                -- most recent timer has expired, so consider the value settled
                { model | sleepCount = 0, settled = model.data } ! []
            else
                -- an earlier timer expired, so input not yet settled
                model ! []
