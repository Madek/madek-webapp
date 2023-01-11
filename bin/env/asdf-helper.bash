function mtime-comps() {
  case "$(uname -s)" in
    Linux*) date -Iseconds --date="$(stat -c '@%Y' $1)" ;;
    Darwin) stat -f %Sm -t "%Y-%m-%dT%H:%M:%S%z" $1 ;;
  esac
}


function asdf-update-plugin () {
  # check asdf is present
  CACHE_ID="${PLUGIN}_${PROJECT}"
  echo "# ${CACHE_ID} env check via asdf $(asdf --version)"
  TMPDIR=${TMPDIR:-/tmp/}
  CACHE_FILE="${TMPDIR}asdf_cache_${CACHE_ID}"

  if [[ ! -e $CACHE_FILE ]] || [[ $(mtime-comps $CACHE_FILE) < $(mtime-comps .tool-versions) ]] ; then
    if $(asdf plugin list | grep -q $PLUGIN); then
      echo "asdf $PLUGIN found: updating "
      asdf plugin update $PLUGIN
    else
      echo "asdf $PLUGIN NOT found: installing "
      asdf plugin add $PLUGIN ${PLUGIN_URL}
    fi
    cd $PROJECT_DIR
    asdf install $PLUGIN
    touch $CACHE_FILE
    echo "# ${CACHE_ID} env is up to date"
  else
    echo "# ${CACHE_ID} env skipped update; touch .tool-versions or remove ${CACHE_FILE} to force update"
  fi
}
# vi: ft=sh
