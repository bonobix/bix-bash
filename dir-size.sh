#!/bin/bash

echo "Seleziona una directory:"
select dir in */ ; do
  if [[ -n "$dir" ]]; then
    du -sh "$dir"
    break
  else
    echo "Scelta non valida."
  fi
done
