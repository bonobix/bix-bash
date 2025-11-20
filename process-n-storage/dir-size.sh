#!/bin/bash

: <<'COMMENT'

Scegli dalla lista e ricevi output della dimensione della directory scelta.

COMMENT

echo "Seleziona una directory:"
select dir in */ ; do
  if [[ -n "$dir" ]]; then
    du -sh "$dir"
    break
  else
    echo "Scelta non valida."
  fi
done
