#!/usr/bin/env bash

if [ ! -d "${HOME}/.zprezto" ]; then
  git clone --quiet --recursive https://github.com/lildude/prezto.git "$HOME/.zprezto" > /dev/null 2>&1
  cd .zprezto
  git remote add upstream https://github.com/sorin-ionescu/prezto.git
  cd - >/dev/null
else
  git -C "${HOME}/.zprezto" pull -q > /dev/null 2>&1
fi

while IFS= read -r -d '' src; do
  dst="$HOME/.$(basename "${src}")"
  display_dst="${dst/$HOME/\~}"
  display_src="${src/$DIR/.zprezto}"
  if [ ! -L "$dst" ]; then
    ln -Ffs "$src" "$dst"
  fi
done <  <(find -H "${HOME}/.zprezto/runcoms/" -maxdepth 1 -not -type d -not -path '*/zlogout' -not -path '*/README.md' -print0)

if [ "$(uname -s)" = "Darwin" ] && [ -z "${CI:-}" ]; then
  if [ "$(dscl . -read "/Users/$USER" UserShell)" != "UserShell: /usr/local/bin/zsh" ]; then
    if ! grep -q /usr/local/bin/zsh /etc/shells; then
      echo '/usr/local/bin/zsh' | sudo tee -a /etc/shells
    fi
    chsh -s /usr/local/bin/zsh
  fi
else
  sudo chsh -s /bin/zsh "$USER"
fi
