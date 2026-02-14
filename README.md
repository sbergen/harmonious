# harmonious

Harmonious is a small Gleam library for the Erlang target,
which can read key presses from a Logitech Harmony Companion remote evdev file.

While originally designed to be used with the Harmony Hub,
the remote is actually just a wireless keyboard,
which will work with a Logitech Unifying receiver.
*However*, not all keys will work with newer versions with the receiver!
I believe I remember reading that C-U0004 is the last version that fully supports the remote,
but I can no longer find the information online!
(If someone has more info on this, please open an issue with it!)

The API is very simple: you use `open` to open the evdev file,
and `read` to perform a (blocking) read of the next key press, repeat, or release.

I acknowledge the error handling could be better,
which is part of the reason why this is not published on hex.
