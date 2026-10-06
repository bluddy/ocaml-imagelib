(** This module provides an easy-to-use interface for image-codec. *)

(** [writefile fn img] writes the image [img] to the file [fn]. This function
    guesses the desired format using the extension.
    Raises {!Corrupted_image} if it encounters a problem.
*)
val writefile : string -> Image.image -> unit

(** [size fn] reads the image from the file [fn].
    It returns the pixel dimensions of the image
    as the tuple [width, height].
*)
val size : string -> int * int

(** [openfile fn] reads the image from the file [fn].
    This function guesses the file format using the extension.
    Raises {!Corrupted_image} if it encounters a problem.
*)
val openfile : string -> Image.image