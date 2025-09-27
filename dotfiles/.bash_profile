if [ -f ~/.bashrc ]; then
  # shellcheck disable=SC1090
  . ~/.bashrc
fi

export HISTCONTROL=ignoreboth:erasedups

# SSH into Windows machine
HOST_IP="$(ip route | grep 'default via' | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
# please add: "Include ~/.ssh/config-windows"
cat >~/.ssh/config-windows <<EOF
Host windows
    Hostname ${HOST_IP}
    User n.izumi
    IdentityFile ~/.ssh/id_ed25519
EOF

# Run ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi
   eval `cat $HOME/.ssh/ssh-agent` > /dev/stderr
fi

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

# user custom binaries
export PATH="$HOME/.local/bin:$PATH"

# asdf
if command -v asdf > /dev/null; then
  export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
  . <(asdf completion bash)
else
  echo 'asdf is not installed' > /dev/stderr
fi

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
      echo 'venv dir exists but activate command does not exist' > /dev/stderr
      return 0
    fi

    # shellcheck disable=SC1090
    source "$venv_contained_dir"/"$activate_bin_path"
  else
    local parent_dir
    local current_dir
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
    if __is_mingw; then
      parent_dir=$(dirname "$VIRTUAL_ENV" | sed -e 's/C:/\/c/' | sed -e 's/\\/\//g')
    else
      parent_dir="$(dirname "$VIRTUAL_ENV")"
    fi
    current_dir=$(pwd -P)
    if [[ "$current_dir"/ != "$parent_dir"/* ]]; then
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

# shellcheck disable=SC1090
. "$HOME/.cargo/env"

# Java
if test -f "$HOME/.asdf/plugins/java/set-java-home.bash"; then
  . "$HOME/.asdf/plugins/java/set-java-home.bash"
fi

# Android SDK
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_HOME=${ANDROID_SDK_ROOT}
export ADB_SERVER_SOCKET=tcp:${HOST_IP}:5037
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator

# Flutter
export PATH=$HOME/flutter/bin:$PATH
