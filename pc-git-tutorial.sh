#!/usr/bin/env bash

parent=f20ec43

declare -A commits
commits[matthias]=6f04408
commits[philippe]=875c18a

remote="https://github.com/pencil-code/pencil-code.git"

tarball="pc-git-tutorial.tar"

developers=${!commits[@]}

function clone
{
    local origin="file://$(pwd)/origin.git"
    local repo="pencil-code-${RANDOM}"

    git init --bare origin.git

    git clone ${remote} ${repo}
    cd ${repo}
    git reset --hard ${parent}
    git push ${origin} master
    cd ..
    rm -rf ${repo}

    for name in ${developers[@]}; do
	git clone ${origin} ${name}
	cd ${name}
	git fetch ${remote} master:pencil
	git format-patch --stdout ..${commits[${name}]} | git apply
	git branch -D pencil
	cd ..
    done

    tar czf ${tarball}.gz origin.git ${developers[@]}
}

rm -rf origin.git ${developers[@]}

if [[ -f ${tarball}.gz ]]; then
    tar xzf ${tarball}.gz
else
    clone
fi
