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
    OG_DIR="$(pwd)"
    cd "$MUSIC_ROOT"
    if [[ ! -d .git ]]; then
        git init
        git remote set origin "$GIT_REMOTE_ORIGIN"
        echo -e "$CHUMHUB_IGNORED_FILE_FORMATS" > .gitignore
    fi
    cd "$OG_DIR"
}

git_sync_remote() {
    OG_DIR="$(pwd)"
    cd "$MUSIC_ROOT"
    git pull
    git add .
    git push -u origin master
    cd "$OG_DIR"
}

build_metafile() {
    OG_DIR="$(pwd)"
    cd "$MUSIC_ROOT"
    metafile='{"collection":['
    while read cover; do
        artist="$(echo $cover | awk -F '/' '{ print $2 }')"
        album="$(echo $cover | awk -F '/' '{ print $3 }')"
        if [[ -e "./$artist/$album/tags" ]]; then
            tags=$(cat "./$artist/$album/tags")
        else
            tags=""
        fi
        entry="{\"artist\":\"$artist\",\"album\":\"$album\",\"tags\":[$tags],"
        entry="$entry\"cover\":\"$cover\"},"
        metafile="$metafile$entry"
    done < <(find . -type f -name "cover.jpg" -or -name "cover.png")
    metafile="${metafile%?}]}"  # ${var%?} => stack overflow black magic to trim last char
    echo "$metafile"
    cd "$OG_DIR"
}

jsonify_tags() {
    tags="$@"
    json_tags=""
    for tag in ${=tags}; do
        json_tags="$json_tags\"$tag\","
    done
    json_tags="${json_tags%?}"
    echo "$json_tags"
}

tag_all_untagged() {
    OG_DIR="$(pwd)"
    cd "$MUSIC_ROOT"
    while read cover <&3; do
        artist="$(echo $cover | awk -F '/' '{ print $2 }')"
        album="$(echo $cover | awk -F '/' '{ print $3 }')"
        if [[ ! -e "./$artist/$album/tags" ]]; then
            echo "$artist - $album"
            echo "Enter tags for this album:"
            read tags
            jsonify_tags $tags > "./$artist/$album/tags"
        fi
    done 3< <(find . -type f -name "cover.jpg" -or -name "cover.png")
    cd "$OG_DIR"
}