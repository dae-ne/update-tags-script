#!/bin/bash

################################################################################
# arguments

v_arg=""    # version
t_arg=""    # type (patch, minor, major)
l_arg=false # local (skip push)

################################################################################
# functions

function update_tags {
  local version=$1
  local skip_push=$2

  echo
  echo "New version: $version"

  echo "Updating tags..."

  echo $version
  git tag -a -m "Release $version" $version

  if [[ $l_arg == false ]]; then
    git push origin $version --quiet
  fi

  tag=$version

  for i in {1..2}
  do
    tag="${tag%.*}"
    echo $tag
    git tag -f -a -m "Updating tag $tag using $version" $tag

    if [[ $l_arg == false ]]; then
      git push origin $tag --force --no-verify --quiet
    fi
  done

  echo "Tags updated successfully"
}

function validate_tag {
  if [[ $1 =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    return
  fi

  echo
  echo "Invalid version format: $1"
  exit 1
}

################################################################################
# main

while getopts ":v:t:l" opt; do
  case $opt in
    v)
      v_arg=$OPTARG
      ;;
    t)
      t_arg=$OPTARG
      ;;
    l)
      l_arg=true
      ;;
    \?)
      echo "Invalid option: $OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option $OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

echo
echo "Fetching tags..."

if [[ $l_arg == false ]]; then
  git tag | xargs git tag -d > /dev/null
  git pull --tags --quiet
fi

tags=$(git tag --sort=-v:refname)

if [[ -n $v_arg ]]; then
  if [[ ${tags[@]} =~ $v_arg ]]; then
    echo
    echo "Tag $v_arg already exists"
    exit 1
  fi

  validate_tag $v_arg
  update_tags $v_arg
  exit 0
fi

tag=$(echo $tags | head -n 1)

if [[ -z $tag ]]; then
  echo
  echo "No tags found. Using v0.0.0"
  tag="v0.0.0"
  update_tags $tag
  exit 0
fi

validate_tag $tag

echo "Current version: $tag"

tag_components=($(echo "${tag#v}" | tr '.' ' '))

major="${tag_components[0]}"
minor="${tag_components[1]}"
patch="${tag_components[2]}"

new_patch=$((patch + 1))
new_minor=$((minor + 1))
new_major=$((major + 1))

new_version_patch="v${major}.${minor}.${new_patch}"
new_version_minor="v${major}.${new_minor}.0"
new_version_major="v${new_major}.0.0"

if [[ -n $t_arg ]]; then
  case $t_arg in
    patch)
      update_tags $new_version_patch
      ;;
    minor)
      update_tags $new_version_minor
      ;;
    major)
      update_tags $new_version_major
      ;;
    *)
      echo "Invalid option $t_arg"
      ;;
  esac
  exit 0
fi

echo
PS3="Select the new version: "

select opt in $new_version_patch $new_version_minor $new_version_major quit; do
  case $opt in
    $new_version_patch)
      update_tags $new_version_patch
      break
      ;;
    $new_version_minor)
      update_tags $new_version_minor
      break
      ;;
    $new_version_major)
      update_tags $new_version_major
      break
      ;;
    quit)
      ;;
    *)
      echo "Invalid option $REPLY"
      ;;
  esac
done
