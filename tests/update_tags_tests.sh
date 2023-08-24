#!/bin/bash

################################################################################
# variables

test_directory=$(dirname "$0")
tests_passed=0

################################################################################
# helpers

function cleanup {
  git tag | xargs git tag -d > /dev/null
  no_tags=$(git tag | wc -l)
}

function pull_tags {
  cleanup
  git pull --tags --quiet
}

function test {
  cleanup
  echo
  echo "!!! running test: $1 !!!"
  $1
  tests_passed=$((tests_passed + 1))
  echo
  echo "!!! passed[$tests_passed]: $1 !!!"
  echo
  cleanup
}

function show_error_message {
  local funcname=$1
  local message=$2

  echo
  echo "!!! error in $funcname !!!"
  echo "!!! $message !!!"
  echo
}

################################################################################
# assert functions

function expect_number_of_tags_to_be {
  local funcname=$1
  local expected=$2
  local actual=$(git tag | wc -l)

  if [[ $expected != $actual ]]; then
    show_error_message $funcname "expected $expected tags, got $actual"
    pull_tags
    exit 1
  fi
}

function expect_version_to_exist {
  local funcname=$1
  local version=$2

  if [[ ! -n $(git tag | grep $version) ]]; then
    show_error_message $funcname "could not find tag $version"
    pull_tags
    exit 1
  fi
}

################################################################################
# tests

function should_create_v1.0.0_version {
  ${test_directory}/../update_tags.sh -v v1.0.0

  expect_number_of_tags_to_be $FUNCNAME 3
  expect_version_to_exist     $FUNCNAME v1.0.0
  expect_version_to_exist     $FUNCNAME v1.0
  expect_version_to_exist     $FUNCNAME v1
}

function should_bump_version_from_v1.0.0_to_v1.0.1 {
  ${test_directory}/../update_tags.sh -v v1.0.0
  ${test_directory}/../update_tags.sh -t patch

  expect_number_of_tags_to_be $FUNCNAME 4
  expect_version_to_exist     $FUNCNAME v1.0.0
  expect_version_to_exist     $FUNCNAME v1.0.1
  expect_version_to_exist     $FUNCNAME v1.0
  expect_version_to_exist     $FUNCNAME v1
}

function should_bump_version_from_v1.0.0_to_v1.1.0 {
  ${test_directory}/../update_tags.sh -v v1.0.0
  ${test_directory}/../update_tags.sh -t minor

  expect_number_of_tags_to_be $FUNCNAME 5
  expect_version_to_exist     $FUNCNAME v1.0.0
  expect_version_to_exist     $FUNCNAME v1.1.0
  expect_version_to_exist     $FUNCNAME v1.0
  expect_version_to_exist     $FUNCNAME v1.1
  expect_version_to_exist     $FUNCNAME v1
}

function should_bump_version_from_v1.0.0_to_v2.0.0 {
  ${test_directory}/../update_tags.sh -v v1.0.0
  ${test_directory}/../update_tags.sh -t major

  expect_number_of_tags_to_be $FUNCNAME 6
  expect_version_to_exist     $FUNCNAME v1.0.0
  expect_version_to_exist     $FUNCNAME v2.0.0
  expect_version_to_exist     $FUNCNAME v1.0
  expect_version_to_exist     $FUNCNAME v2.0
  expect_version_to_exist     $FUNCNAME v1
  expect_version_to_exist     $FUNCNAME v2
}

################################################################################
# run

test should_create_v1.0.0_version
test should_bump_version_from_v1.0.0_to_v1.0.1
test should_bump_version_from_v1.0.0_to_v1.1.0
test should_bump_version_from_v1.0.0_to_v2.0.0

################################################################################
# cleanup

echo "!!! All tests passed: $tests_passed !!!"
pull_tags
echo
