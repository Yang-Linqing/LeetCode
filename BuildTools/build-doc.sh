#!/bin/bash
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2022 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for Swift project authors
#
# Updates the GitHub Pages documentation site thats published from the 'docs'
# subdirectory in the 'gh-pages' branch of this repository.
#
# This script should be run by someone with commit access to the 'gh-pages' branch
# at a regular frequency so that the documentation content on the GitHub Pages site
# is up-to-date with the content in this repo.
#

set -eu

# Use git worktree to checkout the gh-pages branch of this repository in a gh-pages sub-directory
git fetch
git worktree add --checkout gh-pages origin/gh-pages

# Pretty print DocC JSON output so that it can be consistently diffed between commits
export DOCC_JSON_PRETTYPRINT="YES"

# Generate documentation and output it
# to the /docs subdirectory in the gh-pages worktree directory.
export SWIFTPM_ENABLE_COMMAND_PLUGINS=1
swift package \
    --allow-writing-to-directory "gh-pages/docs" \
    generate-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path "/LeetCode" \
    --output-path "gh-pages/docs"
cp BuildTools/custom-index.html gh-pages/docs/index.html
touch gh-pages/docs/.nojekyll

# Save the current commit we've just built documentation from in a variable
CURRENT_COMMIT_HASH=`git rev-parse --short HEAD`

# Commit and push our changes to the gh-pages branch
cd gh-pages
git add docs

if [ -n "$(git status --porcelain)" ]; then
    echo "Documentation changes found. Commiting the changes to the 'gh-pages' branch and pushing to origin."
    git commit -m "Update GitHub Pages documentation site to '$CURRENT_COMMIT_HASH'."
    git push origin HEAD:gh-pages
else
  # No changes found, nothing to commit.
  echo "No documentation changes found."
fi

# Delete the git worktree we created
cd ..
git worktree remove gh-pages
