import gleam/list
import gleeunit
import harmonious.{Event, Pressed, Released}

pub fn main() {
  gleeunit.main()
}

pub fn read_known_file_test() {
  let assert Ok(device) = harmonious.open("test/evdev_capture.bin")
  assert read_until_eof(device, [])
    == [
      Event(458_782, Pressed),
      Event(458_782, Released),
      Event(458_783, Pressed),
      Event(458_783, Released),
      Event(458_784, Pressed),
      Event(458_784, Released),
      Event(786_920, Pressed),
      Event(786_920, Released),
      Event(786_925, Pressed),
      Event(786_925, Released),
      Event(786_921, Pressed),
      Event(786_921, Released),
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
