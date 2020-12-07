module Debounce exposing
    ( Model, Msg(..)
    , init, update
    , settled
    )

{-| This provides a component that can "debounce" a changing value: monitor a
time-varying sequence of values and output the latest value every time there is
no further change for some minimum interval.

This implementation attempts to minimize the number of `update` calls by using
`Process.sleep` to manage the settling time (rather than recalculating elapsed
interval on every fine-grained tick). An added tuple element in the `update`
function's return value provides the notification to the parent of the settled
value. It's also possible to poll the settled value.


# Types

@docs Model, Msg


# Update

@docs init, update


# Read

@docs settled

-}

import Process
import Task
import Time exposing (Time)


{-| Debouncer model. Each instance handles a single time-varying sequence of the
same type (the `datatype`).
-}
type alias Model datatype =
    { data : datatype
    , settled : datatype
    , sleepCount : Int
    , settleTime : Time
    }


{-| Initialize the debouncer with the time to wait for changing values to settle
and the initial settled value.
-}
init : Time -> datatype -> Model datatype
init settleTime val =
    { data = val, settled = val, sleepCount = 0, settleTime = settleTime }


{-| Use the `Change` message to pass a new value to debouncer.
-}
type Msg datatype
    = Change datatype
    | Timeout Int


{-| Access the settled value.
-}
settled : Model datatype -> datatype
settled model =
    model.settled


{-| Update the debouncer as a typical TEA component. The return value adds a
final tuple element that is `Nothing` while the value is still changing and
`Just x` when the value has settled to `x`.
-}
update : Msg datatype -> Model datatype -> ( Model datatype, Cmd (Msg datatype), Maybe datatype )
update msg model =
    case msg of
        Change data_ ->
            let
                count_ =
                    model.sleepCount + 1
            in
            ( { model | data = data_, sleepCount = count_ }
            , Process.sleep model.settleTime |> Task.perform (always (Timeout count_))
            , Nothing
            )

        Timeout count ->
            if count == model.sleepCount then
                -- most recent timer has expired, so consider the value settled
                ( { model | sleepCount = 0, settled = model.data }
                , Cmd.none
                , Just model.data
                )

            else
                -- an earlier timer expired, so input not yet settled
                ( model, Cmd.none, Nothing )



{- Avoid dependency on Basics.Extra by copy-pasting `never` here. -}


never : Never -> a
never x =
    never x
