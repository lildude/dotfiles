#!/usr/bin/env bash
#/ Backup using Restic
#/
#/ This is called by the wrapper script in ${HOME}/.local/gobin/restic-wrapper when executed by launchd
#/ with the binary given full disk access.
#/
set -e

if [ ! -f "$HOME/.config/restic/restic.env" ]; then
  echo "ERROR: No restic.env file found in $HOME/.config/restic"
  exit 1
fi

#shellcheck source=/Users/lildude/.config/restic/restic.env disable=SC1091
source "$HOME/.config/restic/restic.env"
PATH=$PATH:/opt/homebrew/bin/:/usr/local/bin:/usr/bin:/usr/sbin
LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/restic"
export LC_TIME="en_GB.UTF-8"

notify() {
  if tty -s; then
    if hash terminal-notifier 2> /dev/null; then
      terminal-notifier -title "Restic Backup" -message "$1"
    else
      osascript -e "display notification \"$1\" with title \"Restic Backup\""
    fi
  fi
}

# Function called status to record the status of this script to a file
# so that other scripts can check the status of this script
status() {
  echo "$1"
  echo "$(date) $1" >> "$LOGDIR/backup.status" || true
}

if tty -s; then
  #red=$(tput setaf 1)
  #green=$(tput setaf 2)
  yellow=$(tput setaf 3)
  blue=$(tput setaf 4)
  #purple=$(tput setaf 5)
  reset=$(tput sgr0)
fi

# List snapshots of env passed as first arg
if [ "$1" ]; then
  dest=${1^^} # uppercase dest
  repo=${dest}_RESTIC_REPOSITORY
  pass=${dest}_RESTIC_PASSWORD
  export RESTIC_REPOSITORY=${!repo}
  export RESTIC_PASSWORD=${!pass}
  restic snapshots --compact
  exit
fi

mkdir -p "$LOGDIR"

# Prevent running whilst already running, and also prevent sleeping by running via caffeinate
[ -n "$LOCKED" ] || {
  export LOCKED=1
  exec lockrun --lockfile=/tmp/restic-backup.lock -- caffeinate -s "$0" "$@"
}

# Don't run if we're on battery power
pmset -g batt | grep -q "Now drawing from 'Battery Power'" && {
  status "Skipping backups whilst on battery"
  exit 0
}

notify "Starting backup..."

for dest in $DESTS; do
( # Run backups in parallel
  repo=${dest}_RESTIC_REPOSITORY
  pass=${dest}_RESTIC_PASSWORD
  export RESTIC_REPOSITORY=${!repo}
  export RESTIC_PASSWORD=${!pass}
  logfile="$LOGDIR/${dest}.$BASHPID.log"

  { # Group all the subsequent commands so they all output into the same log file
  echo "${blue}*** RESTIC BACKUP SCRIPT STARTED${reset}"

  # change to home dir as all backups are currently relative to $HOME
  cd "$HOME" || exit

  # Only backup to cloud once a day at 19:00
  if [ "$dest" != "LOCAL" ]; then
    if [ "$(date +%H)" != "19" ]; then
      status "$dest: Skipping external backup as it's not 19:00"
      exit 0
    fi
  fi

  if [ "$dest" == "LOCAL" ]; then
    # Mount backup volume
    echo "${yellow}=> Mounting backup volume...${reset}"
    if ! "$HOME/.local/bin/mount-backups" 2>&1; then
      status "$dest: ERROR: failed to mount backup volume"
      notify "🚨 BACKUP FAILED 🚨"
      exit 1
    fi
  fi

  # unlock, in case there's a lock
  echo "${yellow}=> Unlocking restic...${reset}"
  restic unlock

  # --quiet - should speed up backup process see: https://github.com/restic/restic/pull/1676
  echo "${yellow}=> Starting restic backup...${reset}"
  nice -n 19 restic backup \
    --quiet \
    --exclude-caches \
    --files-from "$HOME/.config/restic/include.txt" \
    --exclude-file "$HOME/.config/restic/exclude.txt" || ( notify "🚨 BACKUP FAILED 🚨" && exit 1 )

  printf "\n\n*** Running restic forget with prune....\n"
  # remove outdated snapshots
  nice -n 19 restic forget --keep-last 10 \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --keep-yearly 2 \
    --cleanup-cache \
    --prune

  # Verify the backup by restoring this file and comparing it to the original
  echo "${yellow}=> Verifying backup...${reset}"
  restic restore latest --target /tmp/ --include "/.local/bin/restic-backup" || ( notify "🚨 BACKUP FAILED: Failed to restore file. 🚨" && exit 1 )
  if ! cmp "$HOME/.local/bin/restic-backup" /tmp/.local/bin/restic-backup; then
    notify "🚨 BACKUP FAILED: Restored file doesn't match original 🚨"
    status "$dest: ERROR: Backup verification failed"
    exit 1
  fi
  rm -rf /tmp/.local/

  # Only perform restic check at the end of the day when I'm not likely to be working
  if [ "$(date +%H)" -eq 18 ]; then
    printf "\n\n*** Running restic check....\n"

    # --with-cache - limits Class B Transactions on BackBlaze B2 see: https://forum.restic.net/t/limiting-b2-transactions/209/4
    if [ "$dest" != "LOCAL" ]; then
      check_opt="--with-cache"
    fi
    nice -n 19 restic check $check_opt

    if [ -n "$SHOW_STATS" ]; then
      printf "\n\n*** Running restic stats....\n"
      restic stats

      printf "\n*** Running restic stats for raw-data:\n"
      restic stats --mode raw-data
    fi
  fi

  printf "\n*** RESTIC BACKUP SCRIPT FINISHED\n"

  if [ "$dest" == "LOCAL" ]; then
    echo "${yellow}=> Umounting drives...${reset}"
    "$HOME/.local/bin/umount-backups" 2>&1 || echo "ERROR: failed to umount backup volume"
  fi

  printf "\n===================================================================\n\n\n"
  status "$dest: Backup finished"
  } | ts >> "$logfile"

) &

done

# Wait for all background jobs to finish
for pid in $(jobs -p); do
  wait "$pid"
  # Delete the log files on success - we're only really interested in the log if things go wrong
  if [ -n "$DELETE_LOG_ON_SUCCESS" ]; then
    rm -f $LOGDIR/*.$pid.log
  fi
done

notify "🌈 Backup Finished Successfully 🎉"


