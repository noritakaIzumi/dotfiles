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

# PHP (docker)
DOCKER_PHP_DIR=~/docker-php
DOCKER_PHP_REPO=local/php
docker_php() {
  local version=$1
  local docker_tag=local/php:${version}
  snake_case_version=$(echo "${version}" | tr '.' '_')

  # Remove image
  if [ "$2" = "--remove" ]; then
    docker rmi "$(docker images --quiet --filter=reference=${DOCKER_PHP_REPO}:"${version}")"
    return
  fi

  # Pull latest image
  if [ -z "$(docker images --quiet --filter=reference=${DOCKER_PHP_REPO}:"${version}")" ] || [ "$2" = "--update" ]; then
    docker build --no-cache --pull --file ${DOCKER_PHP_DIR}/Dockerfile."${snake_case_version}" --tag "${docker_tag}" .
  fi

  # Only update
  if [ "$2" = "--update" ]; then
    return
  fi

  # Execute!
  if [ "$2" = "bash" ]; then
    dkrunroot -v "$(pwd)":/app -w /app "${docker_tag}" "${@:2}"
  elif [ -z "$2" ]; then
    dkrun -v "$(pwd)":/app -w /app "${docker_tag}"
  else
    dkrun -v "$(pwd)":/app -w /app "${docker_tag}" php "${@:2}"
  fi
}
for snake_case_version in "${DOCKER_PHP_DIR}"/Dockerfile.*; do
  snake_case_version=$(echo "$snake_case_version" | rev | cut -d'/' -f1 | rev | sed 's/^Dockerfile\.//')
  if [ "$snake_case_version" == "latest" ]; then
    alias dphp='docker_php latest'
  else
    # shellcheck disable=SC2139
    alias "dphp$(echo "$snake_case_version" | tr -d '_')=docker_php $(echo "$snake_case_version" | tr '_' '.')"
  fi
done
