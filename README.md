# elm-debouncer

This module provides a component following The Elm Architecture that can
"debounce" a series of updates to a value.

See example/Main.elm for an example of using this module.

## Related work

https://github.com/pdamoc/elm-assistance provides a similar component. It subscribes to `AnimationFrame.diffs` until the value settles and checks the timestamp of each resulting tick to determine when the settling interval has elapsed.

(athanclark/elm-debouncer)[http://package.elm-lang.org/packages/athanclark/elm-debouncer/2.0.0/Debounce] provides a generalized debouncer. It also uses `Process.sleep` for timing. Its API is a little hard to work out from its docs (for the author of this module, anyway).

