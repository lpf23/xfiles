#!/usr/bin/env bash

_mainScript_() {

  version='2.10'
  destDir="${HOME}/xfiles/config/bash-completion"
  baseUrl='https://github.com/scop/bash-completion/releases/download'
  rawGitUrl='https://raw.githubusercontent.com'
  bashCompletionUrl="${baseUrl}/${version}/bash-completion-${version}.tar.xz"

  declare -A extras=(
    [git]="${rawGitUrl}/git/git/master/contrib/completion/git-completion.bash",
    [docker]="${rawGitUrl}/docker/cli/master/contrib/completion/bash/docker"
  )

  _makeTempDir_
  header "Installing bash-completions"
  _execute_ "curl -sSL \"${bashCompletionUrl}\" | tar -C \"${tmpDir}\" -xJ --strip-components=1"
  _execute_ "cd \"${tmpDir}\""
  _execute_ "./configure --prefix=\"${destDir}\""
  _execute_ "make && make install"

  [ -d "${destDir}/share/bash-completion/completions" ] || fatal "completions directory missing"

  for extra in "${!extras[@]}"; do
    _execute_ "curl -sSL -o \"${destDir}\"/share/bash-completion/completions/\"${extra}\" \"${extras[${extra}]}\"" \
      || fatal "Failed to download: ${extras[${extra}]}"
  done

  source ${destDir}/etc/profile.d/bash_completion.sh

} # end _mainScript_

_sourceHelperFiles_() {
  # DESC: Sources script helper files.
  local filesToSource
  local sourceFile
  filesToSource=(
    "${HOME}/xfiles/scripting/helpers/baseHelpers.bash"
  )
  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "${sourceFile}" ] \
      && {
        echo "error: Can not find sourcefile '$sourceFile'."
        echo "exiting..."
        exit 1
      }
    source "${sourceFile}"
  done
}
_sourceHelperFiles_

# Set initial flags
quiet=false
printLog=false
logErrors=true
verbose=false
force=false
dryrun=false
declare -a args=()

_usage_() {
  cat <<EOF

  ${bold}$(basename "$0") [OPTION]... [FILE]...${reset}

  This is a script template.  Edit this description to print help to users.

  ${bold}Options:${reset}
    -u, --username    Username for script

      $ $(basename "$0") --username 'USERNAME'

    -p, --password    User password

      $ $(basename "$0") --password 'PASSWORD'

    -h, --help        Display this help and exit
    -l, --log         Print log to file with all log levels
    -L, --noErrorLog  Default behavior is to print log level error and fatal to a log. Use
                      this flag to generate no log files at all.
    -n, --dryrun      Non-destructive. Makes no permanent changes.
    -q, --quiet       Quiet (no output)
    -v, --verbose     Output more information. (Items echoed to 'verbose')
    --force           Skip all user interaction.  Implied 'Yes' to all actions.
EOF
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
  while [[ ${1-} == -?* ]]; do
    case $1 in
      -h | --help)
        _usage_ >&2
        _safeExit_
        ;;
      -u | --username)
        shift
        username=${1}
        ;;
      -p | --password)
        shift
        echo "Enter Pass: "
        stty -echo
        read -r PASS
        stty echo
        echo
        ;;
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
set -o errtrace                           # Trap errors in subshells and functions
set -o errexit                            # Exit on error. Append '||true' if you expect an error
set -o pipefail                           # Use last non-zero exit code in a pipeline
# shopt -s nullglob globstar              # Make `for f in *.txt` work when `*.txt` matches zero files
IFS=$' \n\t'                              # Set IFS to preferred implementation
# set -o xtrace                           # Run in debug mode
set -o nounset                            # Disallow expansion of unset variables
# [[ $# -eq 0 ]] && _parseOptions_ "-h"   # Force arguments when invoking the script
#_parseOptions_ "$@"                       # Parse arguments passed to script
# _makeTempDir_ "$(basename "$0")"        # Create a temp directory '$tmpDir'
# _acquireScriptLock_                     # Acquire script lock
_mainScript_                              # Run script
_safeExit_                                # Exit cleanly