#!/bin/sh
set -e
# Example init script, this can be used with nginx, too,
# since nginx and unicorn accept the same signals

# Feel free to change any of the following variables for your app:
TIMEOUT=${TIMEOUT-60}
APP_ROOT=/var/www/sensori
PID=/home/unicorn/pids/unicorn.pid
CMD="export PATH='/usr/local/rvm/gems/ruby-2.1.6/bin:/usr/local/rvm/gems/ruby-2.1.6@global/bin:/usr/local/rvm/rubies/ruby-2.1.6/bin:$PATH'; export GEM_HOME='/usr/local/rvm/gems/ruby-2.1.6'; export GEM_PATH='/usr/local/rvm/gems/ruby-2.1.6:/usr/local/rvm/gems/ruby-2.1.6@global'; export MY_RUBY_HOME='/usr/local/rvm/rubies/ruby-2.1.6'; export IRBRC='/usr/local/rvm/rubies/ruby-2.1.6/.irbrc'; unset MAGLEV_HOME; unset RBXOPT; export RUBY_VERSION='ruby-2.1.6'; cd $APP_ROOT && bundle exec $APP_ROOT/bin/unicorn_rails -D -c $APP_ROOT/config/unicorn.rb -E production"
action="$1"
set -u

old_pid="$PID.oldbin"

cd $APP_ROOT || exit 1

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $old_pid && kill -$1 `cat $old_pid`
}

case $action in
start)
  sig 0 && echo >&2 "Already running" && exit 0
  su -c "$CMD" - rails
  ;;
stop)
  sig QUIT && exit 0
  echo >&2 "Not running"
  ;;
force-stop)
  sig TERM && exit 0
  echo >&2 "Not running"
  ;;
restart|reload)
  sig HUP && echo reloaded OK && exit 0
  echo >&2 "Couldn't reload, starting '$CMD' instead"
  su -c "$CMD" - rails
  ;;
upgrade)
  if sig USR2 && sleep 2 && sig 0 && oldsig QUIT
  then
    n=$TIMEOUT
    while test -s $old_pid && test $n -ge 0
    do
      printf '.' && sleep 1 && n=$(( $n - 1 ))
    done
    echo

    if test $n -lt 0 && test -s $old_pid
    then
      echo >&2 "$old_pid still exists after $TIMEOUT seconds"
      exit 1
    fi
    exit 0
  fi
  echo >&2 "Couldn't upgrade, starting '$CMD' instead"
  su -c "$CMD" - rails
  ;;
reopen-logs)
  sig USR1
  ;;
*)
  echo >&2 "Usage: $0 <start|stop|restart|upgrade|force-stop|reopen-logs>"
  exit 1
  ;;
esac