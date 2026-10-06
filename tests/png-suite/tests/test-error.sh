#!/bin/bash

for IMG in "$@"; do
  echo "Testing ${IMG}"
  image-codec-convert "${IMG}" "${IMG}.ppm" && echo "SHOULD HAVE FAILED"
done