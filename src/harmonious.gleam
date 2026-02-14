pub opaque type Device {
  Device(device: IoDevice, scan_code: Int, status: KeyStatus)
}

pub type KeyStatus {
  Released
  Pressed
  Repeated
}

pub type ReadResult {
  Event(scan_code: Int, status: KeyStatus)
  Eof
  ReadError
}

pub fn open(path: String) -> Result(Device, Nil) {
  case open_file(path) {
    Ok(device) -> Ok(Device(device, 0, Released))
    Error(_) -> Error(Nil)
  }
}

pub fn read(device: Device) -> #(Device, ReadResult) {
  case read_file(device.device) {
    Ok(<<
      _sec:64,
      _usec:64,
      ev_type:16-unsigned,
      code:16-unsigned,
      value:32-signed,
    >>) -> {
      case ev_type, code, value {
        0, 0, 0 -> #(device, Event(device.scan_code, device.status))
        1, _, status -> {
          let status = case status {
            0 -> Released
            1 -> Pressed
            2 -> Repeated
            _ -> panic as "Invalid key value"
          }
          read(Device(..device, status:))
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

type IoDevice

// Erlang failure reason, we don't care about handling individual cases.
type Reason

@external(erlang, "harmonious_ffi", "open")
fn open_file(path: String) -> Result(IoDevice, Reason)

@external(erlang, "harmonious_ffi", "read")
fn read_file(device: IoDevice) -> Result(BitArray, Reason)

@external(erlang, "harmonious_ffi", "is_eof")
fn is_eof(reason: Reason) -> Bool
