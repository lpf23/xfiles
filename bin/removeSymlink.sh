#!/usr/bin/env bash

_mainScript_() {

  _errorHandling_() {
    # This script requires the Linux gdate (as opposed to native 'date' in OSX)
    # Here we see if it's installed. If not, we install it with homebrew.
    if ! command -v dirname &>/dev/null; then
      warning "Need 'dirname' to continue. Installing via homebrew."
      brew install coreutils
      success "'coreutils' package installed. Exiting."
      _safeExit_ "1"
    fi
  }
  _errorHandling_

  [[ ${#args[@]} == 0 ]] && {
    notice "No link(s) specified"
    _safeExit_
  }

  # Work through the links
  for link in "${args[@]}"; do
    verbose "Working on ${tan}${link}${purple}" "$LINENO"
    # Confirm link is actually a symlink
    [ -L "${link}" ] || {
      warning "'${link}': either does not exist or is not a symlink."
      continue
    }

    dir=$(dirname "${link}")
    reltarget=$(readlink "${link}")
    case "${reltarget}" in
      /*) abstarget="${reltarget}" ;;
      *) abstarget="${dir}"/"${reltarget}" ;;
    esac
    if [ -e "${abstarget}" ]; then
      _execute_ "rm -f \"${link}\""
      _execute_ -s "cp -rf \"${abstarget}\" \"${link}\"" "'${link}': Original file copied and symlink removed"
    else
      if _seekConfirmation_ "Can't find original, delete '${link}' anyway?"; then
        _execute_ -s "rm -f \"${link}\"" "Symlink removed"
      fi
    fi

    # If requested, remove the originating file
    if ${replaceSymlink}; then
      if _seekConfirmation_ "Delete originating file?"; then
        _execute_ "rm -rf \"${abstarget}\""
      fi
    fi
  done

}

# Set Flags
quiet=false
printLog=false
logErrors=true
verbose=false
force=false
dryrun=false
declare -a args=()
replaceSymlink=false

_sourceHelperFiles_() {
  local filesToSource
  local sourceFile

  filesToSource=(
    "${HOME}/xfiles/scripting/helpers/baseHelpers.bash"
  )

  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "$sourceFile" ] \
      && {
        echo "error: Can not find sourcefile '$sourceFile'. Exiting."
        exit 1
      }

    source "$sourceFile"
  done
}
_sourceHelperFiles_

_usage_() {
  cat <<EOM

  $(basename "$0") [OPTION]... [SYMLINK]...

  This script will replace symbolic links with their original file.  By default it will COPY
  a version of the original file over the symlink's location.  Specifying the flag '-r' will
  delete the source file of the symlink after copying itself to the symlink's location.

  ${bold}Options:${reset}
    -h, --help        Display this help and exit
    -l, --log         Print log to file
    -L, --noErrorLog  Default behavior is to print log level error and fatal to a log. Use
                      this flag to generate no log files at all.
    -n, --dryrun      Non-destructive. Makes no permanent changes.
    -q, --quiet       Quiet (no output)
    -r, --replace     Replaces the symlink with the original file AND removes the
                      original after copying
    -v, --verbose     Output more information. (Items echoed to 'verbose')
    --force           Skip all user interaction.  Implied 'Yes' to all actions.
EOM
}

_parseOptions_() {
  # Iterate over options
  # breaking -ab into -a -b when needed and --foo=bar into --foo bar
  optstring=h
  unset options
  while (($#)); do
    case $1 in
      # If option is of type -ab
      -[!-]?*)
        # Loop over each character starting with the second
        for ((i = 1; i < ${#1}; i++)); do
          c=${1:i:1}
          options+=("-$c") # Add current char to options
          # If option takes a required argument, and it's not the last char make
          # the rest of the string its argument
          if [[ $optstring == *"$c:"* && ${1:i+1} ]]; then
            options+=("${1:i+1}")
            break
          fi
        done
        ;;
      # If option is of type --foo=bar
      --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
      # add --endopts for --
      --) options+=(--endopts) ;;
      # Otherwise, nothing special
      *) options+=("$1") ;;
    esac
    shift
  done
  set -- "${options[@]}"
  unset options

  # Read the options and set stuff
  while [[ $1 == -?* ]]; do
    case $1 in
      -h | --help)
        _usage_ >&2
        _safeExit_
        ;;
      -r | --replace) replaceSymlink=true ;;
      -L | --noErrorLog) logErrors=false ;;
      -n | --dryrun) dryrun=true ;;
      -v | --verbose) verbose=true ;;
      -l | --log) printLog=true ;;
      -q | --quiet) quiet=true ;;
      --force) force=true ;;
      --endopts)
        shift
        break
        ;;
      *) die "invalid option: '$1'." ;;
    esac
    shift
  done
  args+=("$@") # Store the remaining user input as arguments.
}

# Initialize and run the script
trap '_trapCleanup_ $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[*]}" "$0" "${BASH_SOURCE[0]}"' \
  EXIT INT TERM SIGINT SIGQUIT
set -o errtrace                       # Trap errors in subshells and functions
set -o errexit                        # Exit on error. Append '||true' if you expect an error
set -o pipefail                       # Use last non-zero exit code in a pipeline
shopt -s nullglob globstar            # Make `for f in *.txt` work when `*.txt` matches zero files
IFS=$' \n\t'                          # Set IFS to preferred implementation
# set -o xtrace                       # Run in debug mode
set -o nounset                        # Disallow expansion of unset variables
[[ $# -eq 0 ]] && _parseOptions_ "-h" # Force arguments when invoking the script
_parseOptions_ "$@"                   # Parse arguments passed to script
# _makeTempDir_ "$(basename "$0")"    # Create a temp directory '$tmpDir'
# _acquireScriptLock_                 # Acquire script lock
_mainScript_                          # Run script
_safeExit_                            # Exit cleanly