#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source all readable files in the 'completion' subdirectory
for file in "$DIR/completion.d/"*; do
  [[ -r "$file" && -f "$file" ]] && source "$file"
done
