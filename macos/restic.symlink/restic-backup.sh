#!/usr/bin/env bash
#/ Backup using Restic
#/
#/ These are the accepted environment variables. Set as needed below.
#/
#/ RESTIC_REPOSITORY                   Location of repository (replaces -r)
#/ RESTIC_PASSWORD_FILE                Location of password file (replaces --password-file)
#/ RESTIC_PASSWORD                     The actual password for the repository
#/
#/ AWS_ACCESS_KEY_ID                   Amazon S3 access key ID
#/ AWS_SECRET_ACCESS_KEY               Amazon S3 secret access key
#/
#/ ST_AUTH                             Auth URL for keystone v1 authentication
#/ ST_USER                             Username for keystone v1 authentication
#/ ST_KEY                              Password for keystone v1 authentication
#/
#/ OS_AUTH_URL                         Auth URL for keystone authentication
#/ OS_REGION_NAME                      Region name for keystone authentication
#/ OS_USERNAME                         Username for keystone authentication
#/ OS_PASSWORD                         Password for keystone authentication
#/ OS_TENANT_ID                        Tenant ID for keystone v2 authentication
#/ OS_TENANT_NAME                      Tenant name for keystone v2 authentication
#/
#/ OS_USER_DOMAIN_NAME                 User domain name for keystone authentication
#/ OS_PROJECT_NAME                     Project name for keystone authentication
#/ OS_PROJECT_DOMAIN_NAME              PRoject domain name for keystone authentication
#/
#/ OS_STORAGE_URL                      Storage URL for token authentication
#/ OS_AUTH_TOKEN                       Auth token for token authentication
#/
#/ B2_ACCOUNT_ID                       Account ID or applicationKeyId for Backblaze B2
#/ B2_ACCOUNT_KEY                      Account Key or applicationKey for Backblaze B2
#/
#/ AZURE_ACCOUNT_NAME                  Account name for Azure
#/ AZURE_ACCOUNT_KEY                   Account key for Azure
#/
#/ GOOGLE_PROJECT_ID                   Project ID for Google Cloud Storage
#/ GOOGLE_APPLICATION_CREDENTIALS      Application Credentials for Google Cloud Storage (e.g. $HOME/.config/gs-secret-restic-key.json)
#/
#/ RCLONE_BWLIMIT                      rclone bandwidth limit
set -e

#shellcheck source=/Users/lildude/.restic/restic.env disable=SC1091
source "$HOME/.restic/restic.env"
PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin

notify() {
  if hash terminal-notifier 2> /dev/null; then
    terminal-notifier -title "Restic Backup" -message "$1"
  else
    osascript -e "display notification \"$1\" with title \"Restic Backup\""
  fi
}

#red=$(tput setaf 1)
#green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
#purple=$(tput setaf 5)
reset=$(tput sgr0)

# List snapshots of env passed as first arg
if [ "$1" ]; then
  dest=${1^^} # uppercase dest
  repo=${dest}_RESTIC_REPOSITORY
  pass=${dest}_RESTIC_PASSWORD
  log=${dest}_RESTIC_LOG_FILE
  export RESTIC_REPOSITORY=${!repo}
  export RESTIC_PASSWORD=${!pass}
  export RESTIC_LOG_FILE=${!log}
  restic snapshots --compact
  exit
fi

# Prevent running whilst already running, and also prevent sleeping by running via caffeinate
[ -n "$LOCKED" ] || {
  export LOCKED=1
  exec lockrun --lockfile=/tmp/restic-backup.lock -- caffeinate -s "$0" "$@"
}

# Don't run if we're on battery power
pmset -g batt | grep -q "Now drawing from 'Battery Power'" && {
  notify "Skipping backups whilst on battery"
  exit 0
}

#notify "Started..."

for dest in $DESTS; do
( # Run backups in parallel
  repo=${dest}_RESTIC_REPOSITORY
  pass=${dest}_RESTIC_PASSWORD
  log=${dest}_RESTIC_LOG_FILE
  export RESTIC_REPOSITORY=${!repo}
  export RESTIC_PASSWORD=${!pass}
  export RESTIC_LOG_FILE=${!log}

  { # Group all the subsequent commands so they all output into the same log file
  echo "${blue}*** RESTIC BACKUP SCRIPT STARTED${reset}"

  # change to home dir as all backups are currently relative to $HOME
  cd "$HOME" || exit

  if [ "$dest" == "LOCAL" ]; then
    # Mount backup volume
    echo "${yellow}=> Mounting backup volume...${reset}"
    if ! "$HOME/bin/mount-backups" 2>&1; then
      echo "ERROR: failed to mount backup volume"
      notify "???? FAILED ????"
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
    --files-from "$HOME/.restic/restic-include.txt" \
    --exclude-file "$HOME/.restic/restic-exclude.txt" || ( notify "???? FAILED ????" && exit 1 )

  printf "\n\n*** Running restic forget with prune....n"
  # remove outdated snapshots
  nice -n 19 restic forget --keep-last 10 \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 12 \
    --keep-yearly 2 \
    --cleanup-cache \
    --prune

  # Only perform restic check at the end of the day when I'm not likely to be working
  if [ "$(date +%H)" -eq 19 ]; then
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
    "$HOME/bin/umount-backups" 2>&1 || echo "ERROR: failed to umount backup volume"
  fi

  printf "\n===================================================================\n\n\n"

  } | ts >> "$RESTIC_LOG_FILE"

) &

done

# Wait for all background jobs to finish
for pid in $(jobs -p); do
  wait "$pid"
  # Delete the log files on success - we're only really interested in the log if things go wrong
  if [ -n "$DELETE_LOG_ON_SUCCESS" ]; then
    rm "*.log"
  fi
done

#notify "???? Finished Successfully ????"


