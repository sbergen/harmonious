import argv
import gleam/io
import gleam/string
import harmonious.{type Device}

pub fn main() {
  let assert [filename] = argv.load().arguments
  let assert Ok(device) = harmonious.open(filename)
  read_and_print(device)
}

fn read_and_print(device: Device) {
  let #(device, result) = harmonious.read(device)
  case result {
    harmonious.Event(key:, status:) -> {
      io.println(string.inspect(key) <> ": " <> string.inspect(status))
      read_and_print(device)
    }
    other -> {
      io.println(string.inspect(other))
      Nil
    }
  }
}
