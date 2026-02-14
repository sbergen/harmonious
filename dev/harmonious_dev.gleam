import argv
import gleam/int
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
    harmonious.Event(scan_code:, status:) -> {
      io.println(int.to_string(scan_code) <> ": " <> string.inspect(status))
      read_and_print(device)
    }
    harmonious.Eof | harmonious.ReadError -> Nil
  }
}
