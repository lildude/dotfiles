#!/usr/bin/env bash
#
set -euo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
# shellcheck source=script/lib.sh
source "$DIR/../script/lib.sh"

VERSION=2.7.1

if [ -n "${CI:-}" ]; then
  exit 0
fi

info "I've been replaced by asdf. Doing nothing."
exit 0

rbenv install $VERSION
rbenv global $VERSION
