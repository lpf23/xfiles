alias netCons='lsof -i'                           # netCons:   Show all open TCP/IP sockets
alias lsock='sudo /usr/sbin/lsof -i -P'           # lsock:     Display open sockets
alias lsockU='sudo /usr/sbin/lsof -nP | grep UDP' # lsockU:    Display only open UDP sockets
alias lsockT='sudo /usr/sbin/lsof -nP | grep TCP' # lsockT:    Display only open TCP sockets
alias openPorts='sudo lsof -i | grep LISTEN'      # openPorts: All listening connections
alias showBlocked='sudo ipfw list'                # showBlocked:  All ipfw rules inc/ blocked IPs

lips() {
  # DESC:   Prints local and external IP addresses
  local ip locip extip

  ip=$(ifconfig en0 | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
  [ "$ip" != "" ] && locip="${ip}" || locip="inactive"

  ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
  [ "$ip" != "" ] && extip=${ip} || extip="inactive"

  printf '%11s: %s\n%11s: %s\n' "Local IP" ${locip} "External IP" ${extip}
}
