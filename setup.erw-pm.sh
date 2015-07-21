#!/bin/bash
# EM Feb 14 / update July 15
#
# Requires erw-bash-commons to have been activated
# This script must be sourced from the directory where it is located
#

if [ ! -d TreeTagger ]; then
    echo "Error: TreeTagger has not been installed yet." 1>&2
    echo "Please run 'cd $(pwd) ; bin/tree-tagger-wrapper-install.sh TreeTagger'" 1>&2
    exitOrReturnError
fi
setEnvVar $(pwd)/TreeTagger TREE_TAGGER_PATH
addToEnvVar "$(pwd)/bin" PATH :
