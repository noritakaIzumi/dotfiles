if [ -f ~/.bashrc ]; then
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
  SSH_CONFIG_NAME=$1
  REMOTE_PATH=$2
  MSYS_NO_PATHCONV=1 code --remote ssh-remote+${SSH_CONFIG_NAME} ${REMOTE_PATH}
}

# WSL development
function codewslubuntu() {
  REMOTE_PATH=$1
  MSYS_NO_PATHCONV=1 code --remote wsl+Ubuntu ${REMOTE_PATH}
}

# Node.js version control
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Python version control
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# GOPATH in windows
export GOPATH=/mnt/c/Users/nizum/go/bin

# enable passphrase prompt for gpg
export GPG_TTY=$(tty)
