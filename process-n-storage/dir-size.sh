#!/bin/bash

"""

Scegli dalla lista e ricevi output della dimensione della directory scelta.

"""

echo "Seleziona una directory:"
select dir in */ ; do
  if [[ -n "$dir" ]]; then
    du -sh "$dir"
    break
  else
    echo "Scelta non valida."
  fi
done
