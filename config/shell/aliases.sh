#~~~~~~~~~~~~~~~~#
# SERVER ALIASES #
#~~~~~~~~~~~~~~~~#

# alias SERVERNAME='ssh YOURWEBSITE.com -l USERNAME -p PORTNUMBERHERE'
alias web='cd /var/www/html'
alias tomcat='cd /usr/local/tomcat'
alias apache='cd /usr/local/apache2'

#~~~~~~~~~~~~~~~~~#
# GENERAL ALIASES #
#~~~~~~~~~~~~~~~~~#

# To temporarily bypass an alias, we preceed the command with a \
# EG: the ls command is aliased, but to use the normal ls command you would type \ls
alias sudo='sudo -E '                   # leave a space after sudo to avoid ignoring aliases
alias su='su -p '                       # preserve environment - use wisely
alias ebrc='edit ~/.bashrc'             # Edit this .bashrc file
alias path='echo -e ${PATH//:/\\n}'     # path:     Echo all executable Paths
alias da="date +'%G%m%d%H%M%S'"         # date in the format YYYYMMDDHHMMSS (ISO 8601)

alias cp='cp -iv'                   # Preferred 'cp' implementation
alias mv='mv -iv'                   # Preferred 'mv' implementation
alias mkdir='mkdir -pv'             # Preferred 'mkdir' implementation
alias rm='rm -iv'
alias rmd='/bin/rm -rf '            # Remove a directory and all files

alias cd..='cd ../'                 # Go back 1 directory level (for fast typers)
alias ..='cd ../'                   # Go back 1 directory level
alias ...='cd ../../'               # Go back 2 directory levels
alias .3='cd ../../../'             # Go back 3 directory levels
alias .4='cd ../../../../'          # Go back 4 directory levels
alias .5='cd ../../../../../'       # Go back 5 directory levels
alias .6='cd ../../../../../../'    # Go back 6 directory levels
alias ~="cd ~"                      # ~:      Go Home
alias xfiles='cd ~/xfiles'          # xfiles
alias bd='cd "$OLDPWD"'             # cd into the old directory

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
alias dush="du -sh"
# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

alias fix_stty='stty sane'          # fix_stty:   Restore terminal settings when screwed up
alias ps="ps -ef | grep "
alias kill='kill -9'                # kill:     Preferred 'kill' implementation
mine() { \ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,bsdtime,command; }
alias memHogs='\ps wwaxm -o pid,stat,vsize,rss,time,command | head -10'
alias cpuHogs='\ps wwaxr -o pid,stat,%cpu,time,command | head -10'
alias topcpu="\ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

alias ping='ping -c 10'
alias less='less -R'
alias cls='clear'
alias multitail='multitail --no-repeat -c'
alias freshclam='sudo freshclam'

alias grep='grep --color=always'    # Always color grep
alias fgrep='fgrep --color=always'  # Always color fgrep
alias egrep='egrep --color=always'  # Always color egrep

# alias chmod commands
alias ax='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Make and go to the directory
mcd() {
  mkdir -pv "$1"
  cd "$1" || exit
}

mkcd() { mcd "$1"; }

# Copy and go to the directory
cpg() { 
  [ -d "$2" ] && { cp $1 $2 && cd $2; } || cp $1 $2 
}

# Move and go to the directory
mvg() { 
  [ -d "$2" ] && { mv $1 $2 && cd $2; } || mv $1 $2 
}

# Edit a file with available vi
edit() {
  [ "$(type -t nvim)" = "file" ] && nvim "$@" || /usr/bin/vi "$@"
}

# Sudo edit a file with available vi
sedit() {
  [ "$(type -t nvim)" = "file" ] && sudo ~/xfiles/nvim/bin/nvim "$@" || sudo /usr/bin/vi "$@"
}

# Prefer `prettyping` over `ping`
[[ "$(command -v prettyping)" ]] \
  && alias ping="prettyping --nolegend"

# Prefer we like TLDR
[[ "$(command -v tldr)" ]] \
  && alias help="tldr"

# Prefer `htop` over `top`
[[ "$(command -v htop)" ]] \
  && alias top="htop"

[[ "$(command -v newscript)" ]] \
  && alias ns="newscript"

# Custom commands
[[ $currentShell == "bash" ]] \
  && alias sourcea='source ${HOME}/.bash_profile'
[[ $currentShell == "zsh" ]] \
  && alias sourcea='source ${HOME}/.zshrc'

# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'