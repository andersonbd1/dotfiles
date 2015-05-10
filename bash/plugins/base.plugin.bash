#!/bin/bash

# Generic functions:

genpass() {
  echo "${bold_purple}Generating a ${1} characters long password${normal} =>"
  res=$(openssl rand -base64 ${1} | head -c ${1})
  echo "${bold_green}${res}${normal}"
}

mkcd() {
  mkdir -p "$*"
  cd "$*"
}

man2pdf() {
  man -t "$1" | pstopdf -i -o "$1.pdf"
}

hman() {
  man "$1" | man2html | browser
}

pman() {
  man -t "${1}" | open -f -a "$PREVIEW"
}

quiet() {
  "$@" &> /dev/null &
}

# Determine size of a file or total size of a directory
fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* *;
  fi;
}

# back up file with timestamp, useful for administrators and configs
buf() {
  local filename=$1
  local filetime=$(date +%Y%m%d_%H%M%S)
  cp "${filename}" "${filename}_${filetime}"
}


# Start an HTTP server from a directory, optionally specifying the port
server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}


# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@";
}

# Returns the first command that exists, or exit status 1.
# EDITOR=`first_of "mate -w" "nano -w" vi`
first_of() {
  if [ -n "$1" ]; then
    local arg=$1
    shift
    command -v $arg >> /dev/null && echo $arg || first_of "$@"
  else
    exit 1
  fi
}
