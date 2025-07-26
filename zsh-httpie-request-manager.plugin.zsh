#!/bin/zsh

# configuration
_http_path='/opt/homebrew/bin/http'
_https_path='/opt/homebrew/bin/https'

function http() {
  _httpie_wrapper "$_http_path" "$@"
}

function https() {
  _httpie_wrapper "$_https_path" "$@"
}

function _httpie_wrapper() {
  local httpie_cmd="$1"; shift
  
  # save request to .http file
  local base_dir="$HOME/.httpie/requests"
  [[ ! -d "$base_dir" ]] && mkdir -p "$base_dir"

  # fzf picker for .http files
  if [[ "$1" == list ]]; then
    local base_dir="$HOME/.httpie/requests"
    echo -e "Searching for .http files in $base_dir\n"
    [[ ! -d "$base_dir" ]] && mkdir -p "$base_dir"
    local file
    file=$(
      find "$base_dir" -type f -name '*.http' \
      | fzf --preview 'bat --color=always --style=numbers {}' \
        --height=40% --border \
        --bind 'ctrl-x:execute(rm {})+reload(find '"$base_dir"' -type f -name "*.http")' \
        --bind 'ctrl-e:execute(vim {})+reload(find '"$base_dir"' -type f -name "*.http")+refresh-preview'
    )
    if [[ -n "$file" ]]; then
      echo -e "Selected file: $file\n"

      _httpie_wrapper "$httpie_cmd" "$file" ${@:2}
    else
      echo -e "No file selected."
    fi
    return
  fi

  # save request only if first argument is not a file
  if [[ "$1" != *.http || ! -f "$1" ]]; then
    local TIMESTAMP
    TIMESTAMP=$(date +%Y_%m_%d_at_%H_%M_%S)
    local REQUEST_FILE="${base_dir}/${TIMESTAMP}.http"

    "$httpie_cmd" --offline "$@" > "$REQUEST_FILE"
  fi

  # parsing the .http file
  if [[ "$1" == *.http && -f "$1" ]]; then
    local file="$1"; shift
    local method=""
    local url=""
    local host=""
    local body=""
    local in_body=false
    local headers=()

    while IFS= read -r line || [[ -n "$line" ]]; do
      line="${line%%$'\r'}"
      
      # Don't trim whitespace from body content
      if [[ $in_body == false ]]; then
        line="${line#"${line%%[![:space:]]*}"}"
      fi

      # extract method and URL
      if [[ -z "$method" && "$line" =~ ^(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS|TRACE|CONNECT)\ .* ]]; then
        method="${line%% *}"
        url="${line#* }"
        url="${url%% HTTP/*}"
        url="${url%%$'\r'}"
        continue
      fi

      # extract headers
      if [[ $in_body == false && "$line" =~ ^[A-Za-z-]+:[[:space:]]*.* && ! "$line" =~ ^[Hh]ost:[[:space:]]* ]]; then
        headers+=("$line")
        continue
      fi

      # extract host header
      if [[ $in_body == false && "$line" =~ ^[Hh]ost:[[:space:]]*.* ]]; then
        host="${line#Host: }"
        host="${host%%$'\r'}"
        host="${host%%$'\n'}"
        if [[ ! "$host" =~ ^https?:// ]]; then
          host="https://$host"
        fi
        continue
      fi

      # empty line indicates start of body
      if [[ $in_body == false && -z "$line" ]]; then
        in_body=true
        continue
      fi

      # extract body (everything after headers)
      if [[ $in_body == true ]]; then
        if [[ -z "$body" ]]; then
          body="$line"
        else
          body="$body"$'\n'"$line"
        fi
      fi

    done < "$file"

    # building arguments for httpie
    local args=()
    local is_json=false

    [[ -n "$method" ]] && args+=("$method")
    [[ -n "$host" && -n "$url" ]] && args+=("$host$url")

    for h in "${headers[@]}"; do
      args+=("'$h'")
    done

    for h in "${headers[@]}"; do
      [[ "$h" =~ Content-Type:[[:space:]]*application/json ]] && is_json=true
    done

    if [[ -n "$body" ]]; then
      args+=("--raw" "'$body'")
    fi

    # executing httpie with parsed arguments
    eval "$httpie_cmd ${args[@]} $@"
    return
  fi

  # original httpie command
  $httpie_cmd "$@"
}
