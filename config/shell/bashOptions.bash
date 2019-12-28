if [[ $currentShell == "bash" ]]; then

  ## GENERAL PREFERENCES ##
  
  export XDG_CONFIG_HOME="${HOME}/xfiles"  # Store config files in ~/xfiles directory
  export XDG_DATA_HOME="${XDG_CONFIG_HOME}"
  export BLOCKSIZE=1k
  export LANG="en_US"
  export LC_ALL="en_US.UTF-8"
  export LESS_TERMCAP_md="$ORANGE"         # Highlight section titles in manual pages
  export MANPAGER="less -X"                # Don’t clear the screen after quitting a man page
  export BASHOPTS                          # Preserve shopt opts in subshells
  set -o noclobber                         # Prevent file overwrite on stdout redirection
  shopt -s checkwinsize                    # Update window size after every command
  shopt -s no_empty_cmd_completion         # Don't complete empty command line
  PROMPT_DIRTRIM=3                         # Automatically trim long paths in the prompt (requires Bash 4.x)
  #stty -ixon                               # Allow ctrl-S for history navigation (with ctrl-R)

  ## BETTER DIRECTORY NAVIGATION ##
  shopt -s autocd                          # Prepend cd to directory names automatically
  shopt -s dirspell                        # Correct spelling errors during tab-completion
  shopt -s direxpand                       # Expand directories with completion results
  shopt -s cdspell                         # Correct spelling errors in arguments supplied to cd
  shopt -s nocaseglob                      # Case-insensitive globbing (used in pathname expansion)
  shopt -s extglob                         # Extended pattern matching
  shopt -s globstar 2>/dev/null            # Recursive globbing (enables ** to recurse all directories)
  shopt -s progcomp                        # Enable programable completion
  export CDPATH=".:~:~/xfiles"                             # This defines where cd looks for targets

  ## SMARTER TAB-COMPLETION (Readline bindings) ##
  iatest=$(expr index "$-" i)
  if [[ $iatest > 0 ]]; then
    bind "set bell-style visible"            # Disable the bell
    bind "set completion-ignore-case on"     # Perform file completion in a case insensitive fashion
    bind "set completion-map-case on"        # Treat hyphens and underscores as the same
    bind "set show-all-if-ambiguous on"      # Display matches for ambiguous patterns at first tab press
    bind "set mark-symlinked-directories on" # Add trailing slash when autocompleting symlinks to directories
    bind Space:magic-space                   # typing !!<space> will replace the !! with your last command
  fi
fi

# SSH auto-completion based on entries in known_hosts.
if [[ -e ~/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat "${HOME}/.ssh/known_hosts" | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp sftp
fi