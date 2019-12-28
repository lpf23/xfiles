# Different sets of LS aliases because Gnu LS and macOS LS use different
# flags for colors.  Also, prefer gem colorls when available.

if command -v colorls &>/dev/null; then
  alias ll="colorls -lAtr --sd --gs"
  alias ls="colorls -A --gs"
elif [[ $(command -v ls) =~ gnubin || "$OSTYPE" =~ linux ]]; then
  alias ls="ls --color=auto"
  alias ll="ls -hovArt --color=auto \
    --almost-all \
    --classify \
    --group-directories-first \
    --time-style=+'%G/%m/%d %T'"
else
  alias ls="ls -G"
  alias ll="ls -hovArt \
    --almost-all \
    --classify \
    --group-directories-first \
    --time-style=+'%G/%m/%d %T'"
fi

cd() {
  builtin cd "$@"
  ll
}

# Alias's for multiple directory listing commands
alias la='ls -Alh' # show hidden files
alias lx='ls -lXBh' # sort by extension
alias lk='ls -lSrh' # sort by size
alias lc='ls -lcrh' # sort by change time
alias lu='ls -lurh' # sort by access time
alias lr='ls -lRh' # recursive ls
alias lt='ls -ltrh' # sort by date
alias lm='ls -alh |more' # pipe through 'more'
alias lw='ls -xAh' # wide listing format
alias labc='ls -lap' #alphabetical sort
alias lf="ls -l | egrep -v '^d'" # files only
alias ldir="ls -l | egrep '^d'" # directories only