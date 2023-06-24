if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi

export HISTCONTROL=ignoreboth:erasedups

# SSH into windows machine
# please add: "Include ~/.ssh/config-windows"
cat >~/.ssh/config-windows <<EOF
Host windows
    Hostname $(ip route | grep 'default via' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
    User n.izumi
    IdentityFile ~/.ssh/id_ed25519
EOF

# VSCode remote development
function coderemote() {
  local SSH_CONFIG_NAME=$1
  local REMOTE_PATH=$2
  code --remote ssh-remote+"${SSH_CONFIG_NAME}" "${REMOTE_PATH}"
}

# WSL development
function codewslubuntu() {
  local REMOTE_PATH=$1
  code --remote wsl+Ubuntu "${REMOTE_PATH}"
}

# asdf
if [[ -d $HOME/.asdf ]]; then
  # shellcheck disable=SC1090
  . "$HOME"/.asdf/asdf.sh
  # shellcheck disable=SC1090
  . "$HOME"/.asdf/completions/asdf.bash
else
  echo 'asdf is not installed'
fi

# GOPATH in windows
export GOPATH=/mnt/c/Users/nizum/go/bin

# enable passphrase prompt for gpg
TTY=$(tty)
export GPG_TTY=$TTY

# Random password
# https://serverfault.com/questions/283294/how-to-read-in-n-random-characters-from-dev-urandom
randpw() {
  local COUNT=$1
  head -c 1000 /dev/random | tr -dc '!-~' | fold -w "${COUNT}" | head -n 1
}

__after_cd() {
  # https://stackoverflow.com/questions/45216663/how-to-automatically-activate-virtualenvs-when-cding-into-a-directory
  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the virtualenv
    if [[ -d ./.venv ]] ; then
      source ./.venv/bin/activate
    fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    parentdir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parentdir"/* ]] ; then
      deactivate
    fi
  fi
}

cd() {
  builtin cd "$@"
  __after_cd
}

__after_cd
