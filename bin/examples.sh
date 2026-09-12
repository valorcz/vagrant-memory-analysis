#!/bin/bash

function exercise() {
  # Constants, almost
  export BASEURL="https://www.fi.muni.cz/~xlorenc1/pv204"
  declare -a IMAGES=("homework.vmem.bz2"  "xp-infected.vmem.bz2" "win7_x64.vmem.bz2" "bob.vmem.bz2" "emotetvictim.vmem.bz2")
  maximages=$((${#IMAGES[@]}-1))

  function usage() { # Function: Print a help message.
     echo "Usage: exercise EXERCISE_NUMBER" 1>&2
     echo "    where EXERCISE_NUMBER is in [1,${maximages}]"
  }

  # Test the parameters for validity (preserves 0 as a hidden easter egg)
  if [[ -z "$1" ]] || [[ ! "$1" =~ ^[0-9]+$ ]] || [ "$1" -gt "$maximages" ]; then
    usage
    return 1
  fi

  # Plenty of internal variables to make the script nicer
  image=${IMAGES[$1]}
  lzNumber=$(printf "%02d" "$1")
  target=~/images/exercise${lzNumber}
  plainImage=${image%%.bz2}

  # Create the target folder, if it doesn't exist yet
  mkdir -p "${target}"

  # If the image hasn't been downloaded yet
  if ! [ -s "${target}/${image}" ] && ! [ -s "${target}/${plainImage}" ]; then
    echo "Downloading exercise${lzNumber} image: ${plainImage}..."
    if curl -f -L -# "${BASEURL}/images/${image}" -o "${target}/${image}"; then
      # Does the image need any post-processing?
      if [[ "${image}" == *.bz2 ]]; then
        echo "Extracting the image..."
        bunzip2 -v "${target}/${image}"
      fi
    else
      echo "Download has failed. Please check your internet connection or URL." 1>&2
      rm -f "${target}/${image}"
      return 1
    fi
  fi

  cd "${target}" || return
}
