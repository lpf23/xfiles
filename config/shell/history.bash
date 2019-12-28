PROMPT_COMMAND='history -a'
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"

# https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Allow use to re-edit a faild history substitution.
shopt -s histreedit

# Save multi-line commands as one command
shopt -s cmdhist

# History expansions will be verified before execution.
shopt -s histverify

# Append to the history file, don't overwrite it
shopt -s histappend

export HISTTIMEFORMAT="%m/%d/%Y [%H:%M] "

export HISTFILESIZE=10000
export HISTSIZE=5000

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Don't record some commands
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
bind '"\e[C": forward-char'
bind '"\e[D": backward-char'