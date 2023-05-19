# jq
alias jq='jq -C'

# register SSH config aliases
if [[ -f $HOME/.ssh/config ]]; then
  grep ^Host "$HOME"/.ssh/config | cut -d ' ' -f2 | while IFS= read -r name; do
    # shellcheck disable=SC2139
    alias ssh--"${name}"="ssh ${name}"
  done
fi

# AWS CDK
alias cdk="npx aws-cdk"

# curl via docker
# shellcheck disable=SC2139
alias curli="docker run --rm -v $(pwd):/app -w /app curlimages/curl:latest"

# explorer opens Windows explorer
alias explorer='explorer.exe'

# docker
alias dk='docker'
alias dkc='docker compose'
AS_ME="-u $(id -u):$(id -g)"
# shellcheck disable=SC2139
alias dkrun="dk run ${AS_ME}"
# shellcheck disable=SC2139
alias dkcexec="dkc exec ${AS_ME}"
