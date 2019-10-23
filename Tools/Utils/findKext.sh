#!/bin/bash

function findKext() {
# $1: Kext
# $2: Directory
  find "${@:2}" -name "$1" -not -path \*/PlugIns/* -not -path \*/Debug/*
}
