(*
 * This file is part of Imagelib.
 *
 * Imagelib is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imabelib is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imabelib.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Copyright (C) 2014 Rodolphe Lepigre.
 *)
open Image
open ImageUtil

(** Note: This module is an interface to the pure OCaml implementations of
   various image formats.

   For an easy to use file-based interface, see the [image_codec.unix] findlib
   package distributed with [image-codec].
   You find said interface in [unix/imageCodec_unix.mli] or in the
   documentation for the module {!ImageCodec_unix}.
 *)


(* [size fn] returns a couple [(w,h)] corresponding to the size of the image
   contained via the chunk_reader [ich].
   The exception [{!Corrupted_image} msg] is raised
   in case of problem. *)
val size : extension:string -> ImageUtil.chunk_reader -> int * int
(** [size ~extension:ext ich] uses [ext] to select the image format.
    The leading dot is optional: [".png"] and ["png"] (in any case) are
    equivalent. *)

(* [openfile fn] reads the image in the file [fn]. This function guesses the
   image format using the extension, and raises [{!Corrupted_image} msg] in
   case of problem. *)
val openfile : extension:string -> ImageUtil.chunk_reader -> Image.image
(** [openfile ~extension:ext ich] uses [ext] to select the image format.
    The leading dot is optional: [".png"] and ["png"] (in any case) are
    equivalent. *)

val openfile_streaming : extension:string -> ImageUtil.chunk_reader ->
  [`GIF of ImageGIF.read_state] option ->
  image option * int * [`GIF of ImageGIF.read_state] option
(** see {!ReadImageStreaming.read_streaming} *)

(* [writefile extension och img] writes the image [img] to the chunk reader [och].
   The desired format is specified via [extension]. *)
val writefile : extension:string ->
  ImageUtil.chunk_writer -> Image.image -> unit
(** [writefile ~extension:ext och img] uses [ext] to select the image format.
    The leading dot is optional: [".png"] and ["png"] (in any case) are
    equivalent. *)

module PPM :
  sig
    include WriteImage
    include ReadImage

    module ReadPPM : ReadImage

    type ppm_mode = Binary | ASCII

    val write_ppm : chunk_writer -> image -> ppm_mode -> unit
  end

module PNG :
  sig
    include WriteImage
    include ReadImage

    module ReadPNG : ReadImage

    [@@ocaml.deprecated]
    val write_png : chunk_writer -> image -> unit

    [@@ocaml.deprecated]
    val bytes_of_png : image -> Bytes.t
  end

module JPG :
  sig
    include ReadImage
    include WriteImage

    type subsampling = ImageJPG.subsampling
      = Four_four_four | Four_two_two | Four_two_zero

    val write_jpg : ?quality:int -> ?subsampling:subsampling ->
      chunk_writer -> image -> unit
    (** [write_jpg ?quality ?subsampling cw image] encodes [image] as a
        baseline sequential 8-bit JPEG and writes it to [cw].  [quality] ranges
        from 1 to 100 and scales the example quantisation tables the way
        libjpeg does; it defaults to 75.  [subsampling] selects the chroma
        resolution and defaults to [Four_four_four], i.e. no chroma
        subsampling.  Any alpha channel is ignored, and images whose
        [max_val] exceeds 255 are scaled down to the 8-bit range. *)

    val bytes_of_jpg : ?quality:int -> ?subsampling:subsampling ->
      image -> Bytes.t
    (** [bytes_of_jpg ?quality ?subsampling image] is [write_jpg] into an
        in-memory buffer. *)
  end

module GIF :
  sig
    include ReadImage
    include WriteImage

    val write : chunk_writer -> image -> unit
    (** [write cw image] encodes [image] as a GIF and writes it to [cw].
        At the moment compression is not supported, so the GIF will
        NOT be uncompressed.*)
  end

module BMP :
  sig
    module ReadBMP : ReadImage
  end