import gleam/list
import gleeunit
import harmonious.{Event, Pressed, Released, Repeated}

pub fn main() {
  gleeunit.main()
}

pub fn read_known_file_test() {
  let assert Ok(device) = harmonious.open("test/evdev_capture.bin")
  assert read_until_eof(device, [])
    == [
      Event(harmonious.One, Pressed),
      Event(harmonious.One, Repeated),
      Event(harmonious.One, Released),
      Event(harmonious.Two, Pressed),
    ]
}

fn read_until_eof(
  device: harmonious.Device,
  results: List(harmonious.ReadResult),
) -> List(harmonious.ReadResult) {
  let #(device, result) = harmonious.read(device)
  case result {
    harmonious.Eof -> list.reverse(results)
    _ -> read_until_eof(device, [result, ..results])
  }
}
