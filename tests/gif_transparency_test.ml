open Image
open Bigarray

let test_gif_transparency () =
  (* Create RGBA image with left half opaque, right half transparent *)
  let width = 16 in
  let height = 16 in
  let r = Array2.create int8_unsigned c_layout width height in
  let g = Array2.create int8_unsigned c_layout width height in
  let b = Array2.create int8_unsigned c_layout width height in
  let a = Array2.create int8_unsigned c_layout width height in
  for x = 0 to width - 1 do
    for y = 0 to height - 1 do
      Array2.set r x y 255;
      Array2.set g x y 0;
      Array2.set b x y 0;
      Array2.set a x y (if x < 8 then 255 else 0);
    done
  done;
  let img = { width; height; max_val = 255; pixels = RGBA (Pix8 r, Pix8 g, Pix8 b, Pix8 a) } in
  let buf = Buffer.create 4096 in
  let och = ImageUtil.chunk_writer_of_buffer buf in
  ImageCodec.writefile ~extension:".gif" och img;
  ImageUtil.close_chunk_writer och;
  let data = Buffer.contents buf in
  Alcotest.(check bool) "GIF size > 0" true (String.length data > 0);
  let has_gce = String.contains data (Char.chr 0x21) && String.contains data (Char.chr 0xF9) in
  Alcotest.(check bool) "Has Graphic Control Extension" true has_gce;
  (* Check that transparent index (0) appears in the image data *)
  Alcotest.(check bool) "Uses index 0" true (String.contains data (Char.chr 0x00))

let () =
  Alcotest.run "GIF transparency tests" [
    "transparency", [ "gif with alpha", `Quick, test_gif_transparency ]
  ]
