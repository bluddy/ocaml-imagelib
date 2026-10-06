(* ------------------------------------------------------------------ *)
(* PNG round-trip tests (pure OCaml, no ImageMagick)                  *)
(* ------------------------------------------------------------------ *)

let make_rgb_image w h =
  let img = Image.create_rgb w h in
  for y = 0 to h - 1 do
    for x = 0 to w - 1 do
      Image.write_rgb img x y
        ((x * 255) / max 1 (w - 1))
        ((y * 255) / max 1 (h - 1))
        (((x + y) * 255) / max 1 (w + h - 2))
    done
  done;
  img

let make_grey_image w h =
  let img = Image.create_grey w h in
  for y = 0 to h - 1 do
    for x = 0 to w - 1 do
      Image.write_grey img x y ((x * 17 + y * 13) mod 256)
    done
  done;
  img

let roundtrip_test name img =
  let png_bytes = ImageCodec.PNG.bytes_of_png img in
  let decoded = ImageCodec.PNG.parsefile
      (ImageUtil.chunk_reader_of_string (Bytes.to_string png_bytes)) in
  Alcotest.(check int) (name ^ ": width") img.width decoded.width;
  Alcotest.(check int) (name ^ ": height") img.height decoded.height;
  Alcotest.(check int) (name ^ ": max_val") img.max_val decoded.max_val;
  (* Compare pixel by pixel *)
  let mismatches = ref 0 in
  for y = 0 to img.height - 1 do
    for x = 0 to img.width - 1 do
      let eq =
        match img.pixels, decoded.pixels with
        | Image.RGB (r1,g1,b1), Image.RGB (r2,g2,b2) ->
            Image.Pixmap.get r1 x y = Image.Pixmap.get r2 x y &&
            Image.Pixmap.get g1 x y = Image.Pixmap.get g2 x y &&
            Image.Pixmap.get b1 x y = Image.Pixmap.get b2 x y
        | Image.Grey g1, Image.Grey g2 ->
            Image.Pixmap.get g1 x y = Image.Pixmap.get g2 x y
        | _ -> false
      in
      if not eq then incr mismatches
    done
  done;
  Alcotest.(check int) (name ^ ": pixel match") 0 !mismatches

let rgb_8x8 () = roundtrip_test "rgb 8x8" (make_rgb_image 8 8)
let rgb_16x16 () = roundtrip_test "rgb 16x16" (make_rgb_image 16 16)
let rgb_17x13 () = roundtrip_test "rgb 17x13" (make_rgb_image 17 13)
let rgb_32x32 () = roundtrip_test "rgb 32x32" (make_rgb_image 32 32)
let grey_16x16 () = roundtrip_test "grey 16x16" (make_grey_image 16 16)
let one_pixel_rgb () = roundtrip_test "1x1 rgb" (make_rgb_image 1 1)
let one_pixel_grey () = roundtrip_test "1x1 grey" (make_grey_image 1 1)

let writefile_dispatch () =
  let img = make_rgb_image 16 16 in
  let buf = Buffer.create 4096 in
  let och = ImageUtil.chunk_writer_of_buffer buf in
  ImageCodec.writefile ~extension:".png" och img;
  ImageUtil.close_chunk_writer och;
  let data = Buffer.contents buf in
  Alcotest.(check bool) "produces PNG magic" true
    (String.length data >= 4 && String.sub data 0 4 = "\137PNG")

let unit_tests : unit Alcotest.test_case list = [
  "rgb 8x8 roundtrip", `Quick, rgb_8x8;
  "rgb 16x16 roundtrip", `Quick, rgb_16x16;
  "rgb 17x13 roundtrip", `Quick, rgb_17x13;
  "rgb 32x32 roundtrip", `Quick, rgb_32x32;
  "grey 16x16 roundtrip", `Quick, grey_16x16;
  "1x1 rgb roundtrip", `Quick, one_pixel_rgb;
  "1x1 grey roundtrip", `Quick, one_pixel_grey;
  "writefile dispatches .png", `Quick, writefile_dispatch;
]

let regressions : unit Alcotest.test_case list = []