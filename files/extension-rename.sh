#!/bin/bash

# change extension of files in current dir.
OLD_EXT="log"
NEW_EXT="txt"   # leave empty for no extension

for f in *."$OLD_EXT"; do
  [ -e "$f" ] || continue

  base="${f%.*}"

  if [ -n "$NEW_EXT" ]; then
    mv "$f" "${base}.${NEW_EXT}"
  else
    mv "$f" "${base}"
  fi
done
