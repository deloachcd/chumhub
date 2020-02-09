#!/bin/bash

export MUSIC_ROOT=$HOME/Music
export GIT_REMOTE_ORIGIN="git@github.com:deloachcd/deloachcd.github.io.git"
export CHUMHUB_IGNORED_FILE_FORMATS=$(cat << EOF
**/*.mp3
**/*.ogg
**/*.flac
**/*.alac
**/*.wav
**/*.wma
**/*.aac
**/*.pcm
**/*.aiff
EOF
)

extract_bandcamp_archive() {
    archive="$1"
    music_root="$2"
    if [[ ! "$archive" =~ ".zip" ]]; then
        return
    fi
    if [[ -z "$music_root" ]]; then
        music_root="$MUSIC_ROOT"
    fi
    SEP=" - "
    artist="$(echo "$archive" | awk -F "$SEP" '{ print $1 }')"
    album="$(basename "$archive" .zip | awk -F "$SEP" '{ print $2 }')"
    if [[ ! -d "$music_root/$artist" ]]; then
        mkdir "$music_root/$artist"
    fi
    if [[ ! -d "$music_root/$artist/$album" ]]; then
        mkdir "$music_root/$artist/$album"
    fi
    unzip "$archive" -d "$music_root/$artist/$album"
}

init_repo() {
    cd "$MUSIC_ROOT"
    if [[ ! -d .git ]]; then
        git init
        git remote set origin "$GIT_REMOTE_ORIGIN"
        echo -e "$CHUMHUB_IGNORED_FILE_FORMATS" > .gitignore
    fi
}

git_sync_remote() {
    cd "$MUSIC_ROOT"
    git pull
    git add .
    git push -u origin master
}

build_metafile() {
    OG_DIR="$(pwd)"
    cd "$MUSIC_ROOT"
    metafile='{"collection":['
    while read cover; do
        artist="$(echo $cover | awk -F '/' '{ print $2 }')"
        album="$(echo $cover | awk -F '/' '{ print $3 }')"
        if [[ -e "./$artist/$album/tags" ]]; then
            tags=$(cat tags)
        else
            tags=""
        fi
        entry="{\"artist\":\"$artist\",\"album\":\"$album\",\"tags\":[$tags]},"
        metafile="$metafile$entry"
    done < <(find . -type f -name "cover.jpg" -or -name "cover.png")
    cd $OG_DIR
    metafile="${metafile%?}]}"  # ${var%?} => stack overflow black magic to trim last char
    echo "$metafile"
}