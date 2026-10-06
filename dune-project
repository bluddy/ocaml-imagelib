(lang dune 3.14)
(name image-codec)
(generate_opam_files true)

(authors
  "Yotam Barnoy <yotambarnoy@gmail.com>"
  "Rodolphe Lepigre <lepigre@mpi-sws.org>")
(maintainers
  "Yotam Barnoy <yotambarnoy@gmail.com>")
(source (github bluddy/ocaml-image-codec))
(license "LGPL-3.0-or-later")

(package
 (name image-codec)
 (synopsis "Pure OCaml image codec library")
 (description "The image-codec library implements image formats such as PNG, BMP,
and PPM in OCaml, relying on only one external dependency: 'decompress'.

Unix-dependent functionality such as reading or writing to files in the
filesystem are packaged in the `image_codec.unix` findlib module inside this
OPAM package; to use it you need to include `image_codec.unix` specifically
in your project's dependencies, for instance `(libraries image_codec.unix)`
in your Dune file.

Supported image formats:
 - PNG (full implementation of RFC 2083),
 - PPM, PGM, PBM, ... (fully supported),
 - BMP (read and write, 24-bit RGB),
 - JPEG (read and write),
    - Baseline sequential and progressive DCT decoding, 8-bit samples,
      arbitrary chroma subsampling and restart intervals.  Writing produces
      baseline sequential images.  Arithmetic coding, lossless modes, 12-bit
      samples and CMYK are not supported.
 - GIF (read/write, animated),
    - Native implementation in the pure `ImageCodec` module handles
      interlaced images, local colour tables, disposal methods 0-3, and
      comment extensions.

As image-codec only requires `decompress`, it is suitable for compilation to
javascript using `js_of_ocaml`, or inclusion in MirageOS unikernels.

`app/imagetool.ml` contains an example binary that acts as a command-line
interface to many of the functions in the library. It will be installed as
`imagetool` or `imagetool.exe` if you use **opam** to install the library,
and otherwise it will be in `_build/default/app/imagetool.exe")
 (depends
  (ocaml (>= 5.0.0))
  (decompress (>= 1.5.3))
  (alcotest :with-test)
  (crowbar :with-test)
  (afl-persistent :with-test)))