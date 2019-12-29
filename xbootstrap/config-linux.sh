#!/usr/bin/env bash

_mainScript_() {

  [[ "${OSTYPE}" =~ linux-gnu* ]] || fatal "We are not on Linux"

  # xbootstrap directory is one below parent
  gitRoot=$( cd "$(dirname "${BASH_SOURCE[0]}")"/.. ; pwd -P )

  # CentOS || Ubuntu
  linuxFlavor="$(/usr/bin/awk -F'"' '/^NAME=/{print $2}' /etc/os-release)"
  # Get privs upfront
  /usr/bin/sudo -v

  ##################################################################
  _updateSystem_() {
    # DESC:   Upgrade yum (CentOS)
    # ARGS:   None
    # OUTS:   None
    if ! _seekConfirmation_ "Update System and Install Packages?"; then return; fi

    # Set the package manager based on linuxFlavor
    if [[ "$linuxFlavor" == "CentOS Linux" ]]; then
      packageManager="sudo yum "
      networkTools="bind-utils"
      shellCheck="ShellCheck"
      devPackages="openssl-devel zlib-devel readline-devel"
      javaPackage="java-11-openjdk-devel"
    elif [[ "$linuxFlavor" == "Ubuntu" ]]; then
      packageManager="sudo apt-get "
      networkTools="dnsutils"
      shellCheck="shellcheck"
      devPackages="libssl-dev"
      javaPackage="default-jre"
    else
      fatal "PackageManager not supported for ${linuxFlavor}" ${LINENO}
    fi

    # Upgrade CentOS
    if [[ "$linuxFlavor" == "CentOS Linux" ]]; then
      if [[ -f "/etc/yum.repos.d/CentOS-Base.repo" ]]; then
        header "Upgrading yum...(May take a while)"
        _execute_ -q "sudo yum update -y"
      else
        fatal "Can not proceed without yum" ${LINENO}
      fi
    # Upgrade Ubuntu
    elif [[ "$linuxFlavor" == "Ubuntu" ]]; then
      if [[ -f "/etc/apt/sources.list" ]]; then
        header "Upgrading apt-get...(May take a while)"
        _execute_ -q "sudo apt-get update"
        _execute_ -q "sudo apt-get upgrade -y"
      else
        fatal "Can not proceed without apt-get" ${LINENO}
      fi
    else
      fatal "Package Manager not supported" ${LINENO}
    fi

    header "Installing navigation tools" # Directory/Text/etc Tools
    _execute_ -qp "${packageManager} install -y autojump colordiff less tree jq"
    header "Installing Git stuff" # Git Stuff
    _execute_ -qp "${packageManager} install -y git git-extras"
    header "Installing Network Tools" # Network Tools
    _execute_ -qp "${packageManager} install -y ${networkTools}"  # dnsutils equivalent in ubuntu
    header "Installing System Tools" # System Tools
    _execute_ -qp "${packageManager} install -y coreutils htop"
    header "Installing Zip Tools" # Zip Tools
    _execute_ -qp "${packageManager} install -y bzip2 p7zip unzip"
    header "Installing Web Tools" # Web Tools
    _execute_ -qp "${packageManager} install -y curl httpie wget"

    if _seekConfirmation_ "Install yum development tools?"; then
      header "Installing development tools"
      _execute_ -qp "${packageManager} install -y autoconf automake"
      _execute_ -qp "${packageManager} install -y gcc"           # needed to build rbenv extension, but not required
      _execute_ -qp "${packageManager} install -y ${devPackages}"
      _execute_ -qp "${packageManager} install -y jpegoptim optipng pngcrush"
      _execute_ -qp "${packageManager} install -y python python3 python3-pip"
      _execute_ -qp "${packageManager} install -y ${shellCheck}"
      _execute_ -qp "${packageManager} install -y source-highlight"
    fi

    if ! _seekConfirmation_ "Install Java?"; then return; fi
    header "Installing Java"
    _execute_ -qp "${packageManager} install -y ${javaPackage}"
  }
  ##################################################################
  _setupBashCompletion_() {
    # DESC:   Installs bash completion in ~/xfiles/config/bash-completion
    # ARGS:   None
    # OUTS:   None
    lbc="${HOME}/xfiles/config/bash-completion/etc/profile.d/bash_completion.sh"
    [[ -f $lbc ]] || _execute_ -vs "${HOME}/xfiles/xbootstrap/bashCompletion.sh"
    source $lbc 2> /dev/null
  }
  ##################################################################
  _setupNeoVim_() {
    # DESC:   Installs neovim in ~/xfiles/nvim
    # ARGS:   None
    # OUTS:   None
    [[ -f ${HOME}/xfiles/nvim/bin/nvim ]] || _execute_ -qs "${HOME}/xfiles/xbootstrap/nvim.sh"
  }
  ##################################################################
  _setupRbenv_() {
    # DESC:   Installs prettyping in ~/xfiles/config/rbenv
    # ARGS:   None
    # OUTS:   None
    if [[ ! -d ${HOME}/xfiles/config/rbenv ]]; then
      _execute_ -qs "${HOME}/xfiles/xbootstrap/rbenv.sh"
    fi
  }
  ##################################################################
  _setupTLDR_() {
    # DESC:   Installs tldr in ~/xfiles/bin/tldr
    # ARGS:   None
    # OUTS:   None
    if [[ ! -f ${HOME}/xfiles/bin/tldr ]]; then
      header "Installing TLDR"
      _execute_ -q "curl -o \"${HOME}\"/xfiles/bin/tldr https://raw.githubusercontent.com/raylee/tldr/master/tldr"
      _execute_ -qs "chmod +x \"${HOME}\"/xfiles/bin/tldr"
    fi
  }
  ##################################################################
  _setupPrettyPing_() {
    # DESC:   Installs prettyping in ~/xfiles/bin/prettyping
    # ARGS:   None
    # OUTS:   None
    if [[ ! -f ${HOME}/xfiles/bin/prettyping ]]; then
      header "Installing PrettyPing"
      _execute_ -q "curl -o \"${HOME}\"/xfiles/bin/prettyping https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping"
      _execute_ -qs "chmod +x \"${HOME}\"/xfiles/bin/prettyping"
    fi
  }
  ##################################################################
  _symlinks_() {
    # DESC:   Creates symlinks to dotfiles and custom scripts
    # ARGS:   None
    # OUTS:   None
    if _seekConfirmation_ "Create symlinks to dotfiles and custom scripts?"; then
      header "Creating Symlinks"
      # dotfiles
      _makeSymlink_ "${gitRoot}/config/dotfiles/bash_profile"   "${HOME}/.bash_profile"
      _makeSymlink_ "${gitRoot}/config/dotfiles/bashrc"         "${HOME}/.bashrc"
      _makeSymlink_ "${gitRoot}/config/dotfiles/curlrc"         "${HOME}/.curlrc"
      _makeSymlink_ "${gitRoot}/config/dotfiles/hushlogin"      "${HOME}/.hushlogin"
      _makeSymlink_ "${gitRoot}/config/dotfiles/Gemfile"        "${HOME}/.Gemfile"
      _makeSymlink_ "${gitRoot}/config/dotfiles/gemrc"          "${HOME}/.gemrc"
      _makeSymlink_ "${gitRoot}/config/dotfiles/gitattributes"  "${HOME}/.gitattributes"
      _makeSymlink_ "${gitRoot}/config/dotfiles/gitconfig"      "${HOME}/.gitconfig"
      _makeSymlink_ "${gitRoot}/config/dotfiles/gitignore"      "${HOME}/.gitignore"
      _makeSymlink_ "${gitRoot}/config/dotfiles/inputrc"        "${HOME}/.inputrc"
      _makeSymlink_ "${gitRoot}/config/dotfiles/profile"        "${HOME}/.profile"
      _makeSymlink_ "${gitRoot}/config/dotfiles/ruby-version"   "${HOME}/.ruby-version"
      _makeSymlink_ "${gitRoot}/config/dotfiles/sed"            "${HOME}/.sed"
      # Custom Scripts
      _makeSymlink_ "${gitRoot}/bin/cleanFilenames.sh"          "${HOME}/bin/cleanFilenames"
      _makeSymlink_ "${gitRoot}/bin/git-churn.sh"               "${HOME}/bin/git-churn"
      _makeSymlink_ "${gitRoot}/bin/hashCheck.sh"               "${HOME}/bin/hashCheck"
      _makeSymlink_ "${gitRoot}/bin/newscript.sh"               "${HOME}/bin/newscript"
      _makeSymlink_ "${gitRoot}/bin/removeSymlink.sh"           "${HOME}/bin/removeSymlink"
      _makeSymlink_ "${gitRoot}/bin/seconds.sh"                 "${HOME}/bin/seconds"
      # Tools
      _makeSymlink_ "${gitRoot}/nvim/bin/nvim"                  "${HOME}/bin/nvim"
      _makeSymlink_ "${gitRoot}/bin/tldr"                       "${HOME}/bin/tldr"
      _makeSymlink_ "${gitRoot}/bin/prettyping"                 "${HOME}/bin/prettyping"
    fi
  }
  ####              ####
  ######################
  # BEGIN METHOD CALLS #
  ######################
  ####              ####
  ## Install OS Packages
  _updateSystem_
   #if [[ "$linuxFlavor" == "centos" ]]; then _upgradeYum_;
   #elif [[ "$linuxFlavor" == "ubuntu" ]]; then _upgradeAptGet;
   #else fatal "Currently only processing CentOS & Ubuntu, not this one: " ${linuxFlavor};
   #fi
  ## Install bash-completion
  _setupBashCompletion_
  ## Install nvim
  _setupNeoVim_
  ## Install rbenv
  if _seekConfirmation_ "Install rbenv (ruby version manager)?"; then _setupRbenv_; fi
  ## Install TLDR for help
  _setupTLDR_
  ## Install PrettyPing ping wrapper
  _setupPrettyPing_
  ############
  # SYMLINKS #
  ############
  _symlinks_
  ####              ####
  ######################
  #  END METHOD CALLS  #
  ######################
  ####              ####
} # end _mainScript_ #
##################################################################
##################################################################
_sourceHelperFiles_() {
  # DESC: Sources script helper files
  local filesToSource
  local sourceFile
  filesToSource=(
    "${HOME}/xfiles/scripting/helpers/baseHelpers.bash"
    "${HOME}/xfiles/scripting/helpers/files.bash"
    "${HOME}/xfiles/scripting/helpers/textProcessing.bash"
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
declare -a args=()

_usage_() {
  cat <<EOF
  ${bold}$(basename "$0") [OPTION]...${reset}
  Configures a new computer running linux.  Performs the following
  optional actions:
    * Symlink dotfiles
    * Generates a SSH key
    * Install apt-get and associated packages
    * Install BATs test framework
    * Install Git Friendly
  ${bold}Options:${reset}
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
shopt -s nullglob globstar                # Make `for f in *.txt` work when `*.txt` matches zero files
IFS=$' \n\t'                              # Set IFS to preferred implementation
# set -o xtrace                           # Run in debug mode
#set -o nounset                           # Disallow expansion of unset variables
# [[ $# -eq 0 ]] && _parseOptions_ "-h"   # Force arguments when invoking the script
_parseOptions_ "$@"                       # Parse arguments passed to script
# _makeTempDir_ "$(basename "$0")"        # Create a temp directory '$tmpDir'
_acquireScriptLock_                       # Acquire script lock
_mainScript_                              # Run script unless in 'source-only' mode
_safeExit_                                # Exit cleanly