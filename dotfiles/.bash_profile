if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi

export HISTCONTROL=ignoreboth:erasedups

# SSH into Windows machine
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

# VSCode WSL development
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

# check if terminal is MinGW
__is_mingw() {
  local kernel_name
  kernel_name="$(uname -s)"
  if [[ "${kernel_name^^}" =~ "MINGW" ]]; then
    return 0
  else
    return 1
  fi
}

# overload builtin "cd"
__after_cd() {
  # https://stackoverflow.com/questions/45216663/how-to-automatically-activate-virtualenvs-when-cding-into-a-directory
  if [[ -z "$VIRTUAL_ENV" ]]; then
    local venv_contained_dir
    ## If env folder is found then activate the virtualenv
    if [[ -d ./.venv ]]; then
      venv_contained_dir="."
    elif [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
      local git_repo_root
      git_repo_root="$(git root)"
      if [[ -d "$git_repo_root"/.venv ]]; then
        venv_contained_dir="$git_repo_root"
      fi
    fi

    if [[ -z "$venv_contained_dir" ]]; then
      return 0
    fi

    local activate_bin_path
    if __is_mingw; then
      activate_bin_path=".venv/Scripts/activate"
    else
      activate_bin_path=".venv/bin/activate"
    fi

    if [[ ! -f "$venv_contained_dir"/"$activate_bin_path" ]]; then
      echo 'venv dir exists but activate command does not exist'
      return 0
    fi

    # shellcheck disable=SC1090
    source "$venv_contained_dir"/"$activate_bin_path"
  else
    local parent_dir
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    parent_dir="$(dirname "$VIRTUAL_ENV")"
    if [[ "$PWD"/ != "$parent_dir"/* ]]; then
      deactivate
    fi
  fi
}

cd() {
  builtin cd "$@" || return 1
  __after_cd
}

__after_cd

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# open link in default Windows browser
# https://superuser.com/questions/1262977/open-browser-in-host-system-from-windows-subsystem-for-linux
# https://help.ubuntu.com/community/EnvironmentVariables#Preferred_application_variables
# https://wslutiliti.es/wslu/
export BROWSER=wslview
