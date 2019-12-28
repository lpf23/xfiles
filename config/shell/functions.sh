#!/usr/bin/env bash

###
###
###

halp() {
  # A little helper for man/alias/function info
  # http://brettterpstra.com/2016/05/18/shell-tricks-halp-a-universal-help-tool/
  # Edited to run 'SCRIPT.sh -h' for my own personal scripts

  local currentShell="$(/usr/bin/ps -p $$ | tail -n 1 | awk -F' ' '{print $4}' | sed 's/-//g' | sed -E 's/.*\///g')"
  local apro=0
  local helpstring="Usage: halp COMMAND

  ${bold}Commonly forgotten commands:${reset}
    cleanDS             Remove .DS_Store files
    finderPath          Gets the frontmost path from the Finder
    lips                Prints local and external IP addresses
    ql                  Opens any file in MacOS Quicklook Preview
    "
  local opt OPTIND

  OPTIND=1
  while getopts "kh" opt; do
    case ${opt} in
      k) apro=1 ;;
      h)
        echo -e "${helpstring}"
        return
        ;;
      *) return 1 ;;
    esac
  done
  shift $((OPTIND - 1))

  if [ $# -ne 1 ]; then
    echo -e "${helpstring}"
    return 1
  fi

  local cmd="${1}"
  [[ $currentShell == "zsh" ]] && local cmdtest="$(type -w "${cmd}" | awk -F': ' '{print $2}')"
  [[ $currentShell == "bash" ]] && local cmdtest=$(type -t "${cmd}")

  if [ -z "${cmdtest}" ]; then
    echo -e "${YELLOW}'${cmd}' is not a known command${RESET}"
    if [[ "${apro}" == 1 ]]; then
      man -k "${cmd}"
    else
      return 1
    fi
  fi

  if [[ "${cmdtest}" == "command" || "${cmdtest}" == "file" ]]; then
    local location=$(command -v "${cmd}")
    local bindir="${HOME}/bin/${cmd}"
    if [[ "${location}" == "${bindir}" ]]; then
      echo -e "${YELLOW}${cmd} is a custom script${RESET}\n"
      "${bindir}" -h
    else
      if tldr "${cmd}" &>/dev/null ; then
        tldr "${cmd}"
      else
        man "${cmd}"
      fi
    fi
  elif [[ "${cmdtest}" == "alias" ]]; then
    echo -ne "${YELLOW}${cmd} is an alias:  ${RESET}"
    alias "${cmd}" | sed -E "s/alias $cmd='(.*)'/\1/"
  elif [[ "${cmdtest}" == "builtin" ]]; then
    echo -ne "${YELLOW}${cmd} is a builtin command${RESET}"
    if tldr "${cmd}" &>/dev/null ; then
      tldr "${cmd}"
    else
      man "${cmd}"
    fi
  elif [[ "${cmdtest}" == "function" ]]; then
    echo -e "${YELLOW}${cmd} is a function${RESET}"
    [[ $currentShell == "zsh" ]] && type -f "${cmd}" | tail -n +1
    [[ $currentShell == "bash" ]] && type "${cmd}" | tail -n +2
  fi
}

explain() {
  # about 'explain any bash command via mankier.com manpage API'
  # example '$ explain                # interactive mode. Type commands to explain in REPL'
  # example '$ explain cmd -o | ... # one command to explain it.'

  if [ "$#" -eq 0 ]; then
    while read -r -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=${cmd}"
    done
    echo "Bye!"
  else
    curl -Gs "https://www.mankier.com/api/explain/?cols=$(tput cols)" --data-urlencode "q=$*"
  fi
}

###
###
###

# Copy file with a progress bar
cpp()
{
  set -e
  strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
  | awk '{
  count += $NF
  if (count % 10 == 0) {
    percent = count / total_size * 100
    printf "%3d%% [", percent
    for (i=0;i<=percent;i++)
      printf "="
      printf ">"
      for (i=percent;i<100;i++)
        printf " "
        printf "]\r"
      }
    }
  END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}


# Goes up a specified number of directories  (i.e. up 4)
up ()
{
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}


# Returns the last 2 fields of the working directory
pwdtail ()
{
  pwd|awk -F/ '{nlast = NF -1;print $nlast"/"$NF}'
}


# download a file using curl
# ex: fetch https://website.com/file.zip ./file.zip
fetch() {
  local URL="${1}"
  local DEST="${2}"

  [ -z "${DEST}" ] && DEST="./${URL##*/}"

  local DESTINATION="$(linkread "${DEST}")"

  [ -f "${DESTINATION}" ] && { message "File already exists, exiting..."; return 0; }

  if ! inpath curl; then 
    error "You need to install curl"
    return 1 
  fi

  # create ${DESTINATION} directory
  if ! mkdir -p ${DESTINATION%/*}; then
      error "Failed to create ${DESTINATION%/*}!"
      return 1
  fi

  # create a temporary file for the download
  local TMPFILE=$(tmpfile)

  # download the file
  message "Downloading file ${DESTINATION##*/}"
  if ! curl --location --progress-bar --output ${TMPFILE} ${URL}; then
      error "Failed to fetch: ${URL}"
      return 1
  fi

  mv ${TMPFILE} ${DESTINATION}
}


# uncompress files to specified directory. if no destination specified, exctract to pwd using filename
unpack() {
  local FILENAME="${1}"
  local DEST="${2}"

  [ -z "${DEST}" ] && DEST="./${FILENAME%%.*}"

  local DESTINATION="$(linkread "${DEST}")"

  [[ -d "${DESTINATION}" ]] && { message "Directory already exists, exiting..."; return 0; }

  # create a temporary directory for extraction
  local TMPDIR=$(tmpdir)

  message "Extracting: ${FILENAME##*/} to ${DESTINATION}"

  case ${FILENAME} in
    *.tar*|*.tgz)
        local TAROPTS
        case ${FILENAME} in
            *.gz|*.tgz)
                TAROPTS='-xzf'
                ;;
            *.bz2)
                TAROPTS='-xjf'
                ;;
            *.xz)
                TAROPTS='-xJf'
                ;;
            *.lzma)
                TAROPTS='-x --lzma -f'
                ;;
            *)
                error "Unhandled file type for: ${FILENAME}"
                return 1
            ;;
        esac
        if ! tar -C ${TMPDIR} ${TAROPTS} ${FILENAME}; then
            error "Failed to extract: ${FILENAME}"
            return 1
        fi
        ;;
		*.zip)
				if ! unzip ${FILENAME} ${TMPDIR}; then
						error "Failed to extract: ${FILENAME}"
						return 1
				fi
				;;
	  *.gz)
				if ! gunzip ${FILENAME} ${TMPDIR}; then
						error "Failed to extract: ${FILENAME}"
						return 1
				fi
				;;
	  *.Z)
				if ! uncompress ${FILENAME} ${TMPDIR}; then
						error "Failed to extract: ${FILENAME}"
						return 1
				fi
				;;
		*.7z)
				if ! 7z x ${FILENAME} ${TMPDIR}; then
						error "Failed to extract: ${FILENAME}"
						return 1
				fi
				;;
    *)
        error "Unhandled file type for: ${FILENAME}"
        return 1
        ;;
  esac

  # make sure the extraction results in only a single directory
  local EXTRACTED=( ${TMPDIR}/* )
  if [[ ${#EXTRACTED[@]} != 1 ]]; then
      error "An error occurred while extracting ${FILENAME}, check ${TMPDIR}"
      return 1
  fi

  mv ${EXTRACTED[0]} ${DESTINATION}
}


# Show the current distribution
distribution ()
{
  local dtype
  # Assume unknown
  dtype="unknown"
  
  # First test against Fedora / RHEL / CentOS / generic Redhat derivative
  if [ -r /etc/rc.d/init.d/functions ]; then
    source /etc/rc.d/init.d/functions
    [ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
  
  # Then test against SUSE (must be after Redhat,
  # I've seen rc.status on Ubuntu I think? TODO: Recheck that)
  elif [ -r /etc/rc.status ]; then
    source /etc/rc.status
    [ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
  
  # Then test against Debian, Ubuntu and friends
  elif [ -r /lib/lsb/init-functions ]; then
    source /lib/lsb/init-functions
    [ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
  
  # Then test against Gentoo
  elif [ -r /etc/init.d/functions.sh ]; then
    source /etc/init.d/functions.sh
    [ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
  
  # For Mandriva we currently just test if /etc/mandriva-release exists
  # and isn't empty (TODO: Find a better way :)
  elif [ -s /etc/mandriva-release ]; then
    dtype="mandriva"

  # For Slackware we currently just test if /etc/slackware-version exists
  elif [ -s /etc/slackware-version ]; then
    dtype="slackware"

  fi
  echo $dtype
}


# Show the current version of the operating system
ver ()
{
  local dtype
  dtype=$(distribution)

  if [ $dtype == "redhat" ]; then
    if [ -s /etc/redhat-release ]; then
      cat /etc/redhat-release && uname -a
    else
      cat /etc/issue && uname -a
    fi
  elif [ $dtype == "suse" ]; then
    cat /etc/SuSE-release
  elif [ $dtype == "debian" ]; then
    lsb_release -a
    # sudo cat /etc/issue && sudo cat /etc/issue.net && sudo cat /etc/lsb_release && sudo cat /etc/os-release # Linux Mint option 2
  elif [ $dtype == "gentoo" ]; then
    cat /etc/gentoo-release
  elif [ $dtype == "mandriva" ]; then
    cat /etc/mandriva-release
  elif [ $dtype == "slackware" ]; then
    cat /etc/slackware-version
  else
    if [ -s /etc/issue ]; then
      cat /etc/issue
    else
      echo "Error: Unknown distribution"
      exit 1
    fi
  fi
}

# View Apache logs
apachelog ()
{
  if [ -f /etc/httpd/conf/httpd.conf ]; then
    cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
  else
    cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
  fi
}


# Edit the Apache configuration
apacheconfig ()
{
  if [ -f /etc/httpd/conf/httpd.conf ]; then
    sedit /etc/httpd/conf/httpd.conf
  elif [ -f /etc/apache2/apache2.conf ]; then
    sedit /etc/apache2/apache2.conf
  else
    echo "Error: Apache config file could not be found."
    echo "Searching for possible locations:"
    sudo updatedb && locate httpd.conf && locate apache2.conf
  fi
}


# For some reason, rot13 pops up everywhere
rot13 () {
  if [ $# -eq 0 ]; then
    tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
  else
    echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
  fi
}