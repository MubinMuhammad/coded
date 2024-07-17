#!/bin/bash
rm -fr ./zig-out ./.zig-cache
git add .
git commit -m $1
git push
