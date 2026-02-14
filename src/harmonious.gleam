pub opaque type Device {
  Device(device: IoDevice, scan_code: Int, status: KeyStatus)
}

pub type Key {
  Off
  Music
  Tv
  Movie
  Red
  Green
  Yellow
  Blue
  Dvr
  Guide
  Info
  Exit
  Menu
  VolUp
  VolDown
  Left
  Right
  Up
  Down
  OK
  ProgramUp
  ProgramDown
  Mute
  Back
  Rewind
  Forward
  Record
  Stop
  Play
  Pause
  One
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Zero
  Minus
  Enter
}

pub type KeyStatus {
  Released
  Pressed
  Repeated
}

pub type ReadResult {
  Event(key: Key, status: KeyStatus)
  Eof
  InvalidKeyValue
  UnknownScanCode
  ReadError
}

/// Opens an evdev device (file) to read.
pub fn open(path: String) -> Result(Device, Nil) {
  case open_file(path) {
    Ok(device) -> Ok(Device(device, 0, Released))
    Error(_) -> Error(Nil)
  }
}

/// Reads the next key press, and returns the new state of the device and the result.
pub fn read(device: Device) -> #(Device, ReadResult) {
  case read_file(device.device) {
    Ok(<<
      _sec:64-native,
      _usec:64-native,
      ev_type:16-native-unsigned,
      code:16-native-unsigned,
      value:32-native-signed,
    >>) -> {
      case ev_type, code, value {
        0, 0, 0 | 0, 0, 1 -> {
          case scan_code_to_key(device.scan_code) {
            Ok(key) -> #(device, Event(key, device.status))
            _ -> #(device, UnknownScanCode)
          }
        }
        1, _, status -> {
          let status = case status {
            0 -> Ok(Released)
            1 -> Ok(Pressed)
            2 -> Ok(Repeated)
            _ -> Error(Nil)
          }
          case status {
            Ok(status) -> read(Device(..device, status:))
            _ -> #(device, InvalidKeyValue)
          }
        }
        4, 4, scan_code -> read(Device(..device, scan_code:))
        _, _, _ -> read(device)
      }
    }
    Error(e) ->
      case is_eof(e) {
        True -> #(device, Eof)
        False -> #(device, ReadError)
      }
    _ -> #(device, Eof)
  }
}

fn scan_code_to_key(scan_code: Int) -> Result(Key, Nil) {
  case scan_code {
    786_924 -> Ok(Off)

    786_920 -> Ok(Music)
    786_925 -> Ok(Tv)
    786_921 -> Ok(Movie)

    786_935 -> Ok(Red)
    786_934 -> Ok(Green)
    786_933 -> Ok(Yellow)
    786_932 -> Ok(Blue)

    786_586 -> Ok(Dvr)
    786_573 -> Ok(Guide)
    786_943 -> Ok(Info)

    786_580 -> Ok(Exit)
    458_853 -> Ok(Menu)

    786_665 -> Ok(VolUp)
    786_666 -> Ok(VolDown)

    786_588 -> Ok(ProgramUp)
    786_589 -> Ok(ProgramDown)

    458_834 -> Ok(Up)
    458_833 -> Ok(Down)
    458_832 -> Ok(Left)
    458_831 -> Ok(Right)
    458_840 -> Ok(OK)

    786_658 -> Ok(Mute)
    786_980 -> Ok(Back)

    786_612 -> Ok(Rewind)
    786_611 -> Ok(Forward)
    786_610 -> Ok(Record)
    786_615 -> Ok(Stop)
    786_608 -> Ok(Play)
    786_609 -> Ok(Pause)

    458_782 -> Ok(One)
    458_783 -> Ok(Two)
    458_784 -> Ok(Three)
    458_785 -> Ok(Four)
    458_786 -> Ok(Five)
    458_787 -> Ok(Six)
    458_788 -> Ok(Seven)
    458_789 -> Ok(Eight)
    458_790 -> Ok(Nine)
    458_791 -> Ok(Zero)

    458_838 -> Ok(Minus)
    458_792 -> Ok(Enter)

    _ -> Error(Nil)
  }
}

type IoDevice

// Erlang failure reason, we don't care about handling individual cases.
type Reason

@external(erlang, "harmonious_ffi", "open")
fn open_file(path: String) -> Result(IoDevice, Reason)

@external(erlang, "harmonious_ffi", "read")
fn read_file(device: IoDevice) -> Result(BitArray, Reason)

@external(erlang, "harmonious_ffi", "is_eof")
fn is_eof(reason: Reason) -> Bool
