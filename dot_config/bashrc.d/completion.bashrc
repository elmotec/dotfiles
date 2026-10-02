#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bind 'set completion-map-case off'
bind 'set show-all-if-ambiguous on'

# Source all readable files in the 'completion' subdirectory
for file in "$DIR/completion.d/"*; do
  [[ -r "$file" && -f "$file" ]] && source "$file"
done
