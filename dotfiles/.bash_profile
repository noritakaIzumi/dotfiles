if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi

export HISTCONTROL=ignoreboth:erasedups

# SSH into windows machine
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

# ruby environment
if [[ -d $HOME/.rbenv ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init - bash)"
else
  echo 'rbenv is not installed'
fi

# Node.js version control
if [[ -d $HOME/.nvm ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
else
  echo 'nvm is not installed'
fi

# Python version control
if [[ -d $HOME/.pyenv ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
else
  echo 'pyenv is not installed'
fi

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
  head -c 1000 /dev/urandom | tr -dc '!-~' | fold -w "${COUNT}" | head -n 1
}
