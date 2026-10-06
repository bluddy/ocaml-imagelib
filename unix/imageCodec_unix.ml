open Image
open ImageUtil_unix

let size fn =
  let extension = Filename.extension fn in
  let ich = chunk_reader_of_path fn in
  ImageCodec.size ~extension ich

let openfile fn : image =
  let extension = Filename.extension fn in
  let ich = chunk_reader_of_path fn in
  ImageCodec.openfile ~extension ich

let writefile fn i =
  let extension = Filename.extension fn in
  let och = ImageUtil_unix.chunk_writer_of_path fn in
  ImageCodec.writefile ~extension och i