#!/usr/bin/env bash

_mainScript_() {

  _errorHandling_() {
    [[ "${#args[@]}" -eq 0 ]] && {
      error "No file specified"
      _safeExit_ 1
    }

    # This script requires the Linux gdate (as opposed to native 'date' in OSX)
    # Here we see if it's installed. If not, we install it with homebrew.
    if [[ "$OSTYPE" =~ darwin* ]]; then
      (_checkBinary_ gdate) || fatal "Need 'coreutils' to continue. Please install via homebrew."
    fi
  }
  _errorHandling_

  _isGoodFile_() {
    if [ ! -e "${userFile}" ]; then
      (${suppressFileTypeErrors}) || error "No such file: '${userFile}'" "${LINENO}"
      return 1
    elif [ ! -f "${userFile}" ]; then
      (${suppressFileTypeErrors}) || error "'${userFile}' is not a file" "${LINENO}"
      return 1
    elif [[ "$(basename "$userFile")" =~ ^\. ]]; then
      (${suppressFileTypeErrors}) || error "$(basename "$userFile"): is a dotfile" "${LINENO}"
      return 1
    elif [[ "${userFile##*.}" =~ dmg$|download$ ]]; then
      (${suppressFileTypeErrors}) || error "'.${userFile##*.}' files are not supported" "${LINENO}"
      return 1
    else
      return 0
    fi
  }

  for userFile in "${args[@]}"; do

    verbose "Working on file: ${tan}${userFile}${purple}"

    if ${testOutput}; then
      notice "Running in test mode. No files will be altered."
      _makeTempDir_
      userFile="${tmpDir}/${userFile}"
      touch "${userFile}"
      verbose "Created test file: ${tan}${userFile}${purple}"
    fi

    if ! _isGoodFile_; then
      if [[ "$userFile" == "${args[-1]}" ]]; then
        _safeExit_ 1
      else
        continue
      fi
    else
      # Remove special characters that can cause problems before we do anything else
      testFilename="${userFile//[\[\]]/}"
      verbose "testFilename: ${testFilename}"

      if [[ "${testFilename}" != "${userFile}" ]]; then
        notice "Filename contains restricted special characters. Removing them to continue..."
        _execute_ "mv \"${userFile}\" \"${testFilename}\""
        userFile="${testFilename}"
      fi

      # Parse the filename into its component parts
      _parseFilename_ "${userFile}"
      savedFileName="${_parseFileName}" # Save the original filename for future comparison
      verbose "${tan}\$savedFileName: ${savedFileName}${purple}"

      # Clean the filename
      _parseFileBase="$(_cleanString_ -a "${_parseFileBase}")"
      ("$stopwords") && _parseFileBase="$(_stopWords_ "${_parseFileBase}")"
      ("$lowerCase") && _parseFileBase="$(_cleanString_ -l "${_parseFileBase}")"
      ("$useDashes") && _parseFileBase="$(_cleanString_ -p " ,-" "${_parseFileBase}")"
      verbose "Cleaned String: ${_parseFileBase}"

      # Find a date for the file or use today's date and format as YYYY-MM-DD
      if ! "${cleanOnly}"; then
        if _parseDate_ "${_parseFileBase}"; then
          fileDate="$(_formatDate_ "${_parseDate_monthName} ${_parseDate_day}, ${_parseDate_year}")"
        else
          if command -v mdls &>/dev/null; then
            inferredDate="$(mdls -raw -name kMDItemContentCreationDate "${_parsedFileFull}" | awk 'BEGIN { FS="[ ]" } ; { print $1 }')"
            [[ "${inferredDate}" =~ null || "${inferredDate}" == "" || -z "${inferredDate}" ]] && inferredDate="$(date +%Y-%m-%d)"
          else
            inferredDate="$(date +%Y-%m-%d)"
          fi
          fileDate="$(_formatDate_ "${inferredDate}")"
        fi
        fileDate="$(echo "${fileDate}" | awk '{$1=$1};1')" # Clean trailing/leading whitespace
        verbose "${tan}\$fileDate: ${fileDate}${purple}"
      fi

      # Strip found date from file
      [ -n "${_parseDate_found:-}" ] && _parseFileBase="${_parseFileBase//${_parseDate_found}/}"

      # Trim special characters from beginning and end
      _parseFileBase="$(echo "$_parseFileBase" | sed -E 's/[^A-Za-z0-9]$//g' | sed -E 's/^[^A-Za-z0-9]//g')"

      # Add the formatted date back to the filename
      if ! "${removeDates}" && ! "${cleanOnly}"; then
        _parseFileBase="${fileDate} ${_parseFileBase}"
      fi

      # Replace the old file with the new file
      _parseFileBase="$(_cleanString_ -a "${_parseFileBase}")"
      ("$useDashes") && _parseFileBase="$(_cleanString_ -p " ,-" "${_parseFileBase}")"

      newFilename="${_parseFileBase}${_parseFileExt}"
      verbose "${tan}\$newFilename: ${newFilename}${purple}"

      # If the filename has not changed then do nothing
      if [[ "${newFilename}" == "${savedFileName}" ]]; then
        if ${nonInteractive}; then
          echo "${_parsedFileFull}"
        else
          notice "${savedFileName}: No change"
        fi
        continue
      fi

      # If the only change was upper/lower replace the file
      shopt -s nocasematch
      if [[ "${newFilename}" == "${savedFileName}" ]]; then
        _makeTempDir_
        _execute_ -q "mv \"${_parsedFileFull}\" \"${tmpDir}/${savedFileName}\""
        [ -f "${tmpDir}/${savedFileName}" ] \
          && _parsedFileFull="${tmpDir}/${savedFileName}"
      fi
      shopt -u nocasematch

      newFile="$(_uniqueFileName_ "${_parseFilePath}/${newFilename}")"
      verbose "newFile: ${tan}${newFile}{$purple}"

      _execute_ -s "command mv \"${_parsedFileFull}\" \"${newFile}\"" "${savedFileName} --> ${newFilename##*/}"

      if ${nonInteractive}; then echo "${newFile}"; fi
    fi

  done

} # end _mainScript_

_sourceHelperFiles_() {
  # DESC: Sources script helper files
  local filesToSource
  local sourceFile
  filesToSource=(
    "${HOME}/xfiles/scripting/helpers/baseHelpers.bash"
    "${HOME}/xfiles/scripting/helpers/files.bash"
    "${HOME}/xfiles/scripting/helpers/textProcessing.bash"
    "${HOME}/xfiles/scripting/helpers/dates.bash"
  )
  for sourceFile in "${filesToSource[@]}"; do
    [ ! -f "$sourceFile" ] \
      && {
        echo "error: Can not find sourcefile '$sourceFile'."
        echo "exiting..."
        exit 1
      }
    source "$sourceFile"
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
suppressFileTypeErrors=false
declare -a args=()

cleanOnly=false
nonInteractive=false
lowerCase=false
ignoreFile=false
removeDates=false
testOutput=false
useDashes=false
stopwords=false

_usage_() {
  cat <<EOF

  $(basename "$0") [OPTION]... [FILE]...

  Performs the following operations on the filename:

      * Prepends a date in the format YYYY-MM-DD
      * Cleans up special characters
      * Trims unneeded whitespace
      * Moves all .jpeg extensions to .jpg
      * Ensures that all file extensions are lowercase

  ${bold}Dates in filenames${reset}
  The date to be added to the filename is discerned by matching the following rules. The
  first of these to be true is used as the date.

      1) A date already exists in the filename.
        In this scenario, the existing date is removed from the filename and is added
        to the front in the form YYYY-MM-DD. The known patterns are:

                 * YYYY-MM-DD      * Month DD, YYYY    * DD Month, YYYY
                 * Month, YYYY     * Month, DD YY      * MM-DD-YYYY
                 * MMDDYYYY        * YYYYMMDD          * DDMMYYYY
                 * YYYYMMDDHHMM    * YYYYMMDDHH        * DD-MM-YYYY
                 * MM DD YY        * DD MM YY

      2) The date the file was created
      3) Today's date

  ${bold}Options:${reset}

    -C, --clean       Cleans a filename of special characters and normalizes dates
                      already in the filename but does NOT prepend a date if none
                      been made.
                      exists
    -D, --useDashes   Convert spaces to dashes
    -e, --noErrorLog  Default behavior is to print log level error and fatal to a log. Use
                      this flag to generate no log files at all.
    -h, --help        Display this help and exit
    -l, --log         Print log to file
    -L, --lower       Transforms the filename to all lower case characters
    -n, --dryrun      Non-destructive run. Will report on changes that would have
    -q, --quiet       Quiet (no output to terminal)
    -R, --removeDate  Removes dates from filenames
    -S, --stopwords   Remove common stop words
    -T, --test        Takes a string of input and shows the result that the script would produce
    -v, --verbose     Output more information.
    --NoFileTypeError Suppress error logging of incompatible file types (directories, etc.)
    --nonInteractive  Assumes the script is being called from another script. The only
                      output in this mode is an exit code and the cleaned name of the file
                      passed to the script

  ${bold}Usage:${reset}

    $ $(basename "$0") "filename (with special chars & and date) 08312016.txt"

          --> 2016-08-31 filename with special chars and date.txt

    $ $(basename "$0") --useDashes "2019-06-01 this is a test file.txt"

          --> 2019-06-01-this-is-a-test-file.txt

    $ $(basename "$0") --stopWords "2019-06-01 this is a test file.txt"

          --> 2019-06-01 file.txt
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
  while [[ ${1:-} == -?* ]]; do
    case $1 in
      -h | --help)
        _usage_ >&2
        _safeExit_
        ;;
      -T | --test)
        testOutput=true
        ;;
      -C | --clean) cleanOnly=true ;;
      -R | --removeDate) removeDates=true ;;
      -S | --stopwords) stopwords=true ;;
      -L | --lower) lowerCase=true ;;
      -e | --noErrorLog) logErrors=false ;;
      -D | --useDashes) useDashes=true ;;
      -n | --dryrun) dryrun=true ;;
      -v | --verbose) verbose=true ;;
      -l | --log) printLog=true ;;
      -q | --quiet) quiet=true ;;
      --nonInteractive)
        nonInteractive=true
        quiet=true
        ;;
      --NoFileTypeError) suppressFileTypeErrors=true ;;
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
trap '_trapCleanup_ $LINENO $BASH_LINENO "${BASH_COMMAND} while working on ${args[*]}" "${FUNCNAME[*]}" "$0" "${BASH_SOURCE[0]}"' \
  EXIT INT TERM SIGINT SIGQUIT
set -o errtrace                       # Trap errors in subshells and functions
set -o errexit                        # Exit on error. Append '||true' if you expect an error
set -o pipefail                       # Use last non-zero exit code in a pipeline
#shopt -s nullglob globstar           # Make `for f in *.txt` work when `*.txt` matches zero files
IFS=$' \n\t'                          # Set IFS to preferred implementation
# set -o xtrace                       # Run in debug mode
set -o nounset                        # Disallow expansion of unset variables
[[ $# -eq 0 ]] && _parseOptions_ "-h" # Force arguments when invoking the script
# _makeTempDir_ "$(basename "$0")"    # Create a temp directory '$tmpDir'
# _acquireScriptLock_                 # Acquire script lock
_parseOptions_ "$@"                   # Parse arguments passed to script
_mainScript_                          # Run script
_safeExit_                            # Exit cleanly