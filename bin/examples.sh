#!/bin/bash

function exercise() {
  # Constants, almost
  export BASEURL="https://dior.ics.muni.cz/~valor/pv204"
  declare -a IMAGES=("homework.vmem.bz2"  "xp-infected.vmem.bz2" "win7_x64.vmem.bz2" "bob.vmem.bz2", "emotetvictim.vmem.bz2")
  maximages=$((${#IMAGES[@]}-1))

  function usage() { # Function: Print a help message.
     echo "Usage: exercise EXERCISE_NUMBER" 1>&2
     echo "    where EXERCISE_NUMBER is in [1,${maximages}]"
  }

  # Test the parameters for validity (could be improved, but at least something)
  if [ "$1" = "" ] || [ $1 -gt $maximages ]; then
    usage;
    return 1
  fi

  # Plenty of internal variables to make the script nicer
  image=${IMAGES[$1]}
  lzNumber=$(printf "%02d" $1)
  target=~/images/exercise${lzNumber}
  plainImage=${image%%.bz2}

  # Create the target folder, if it doesn't exist yet
  mkdir -p ${target}

  # If the image hasn't been downloaded yet
  if ! [ -s ${target}/${image} -o -s ${target}/${plainImage} ]; then
    echo "Downloading exercise${lzNumber} image: ${plainImage}..."
    curl -# ${BASEURL}/images/${image} -o ${target}/${image}

    # Successful download?
    if [ 0 -eq $? ]; then
      # Does the image need any post-processing?
      if [[ "${image}" == *.bz2 ]]
      then
        echo "Extracting the image..."
        bunzip2 -v ${target}/${image}
      fi # post-processing
    else
      echo "Download has failed"
    fi
  fi # existence

  cd ${target}
}
