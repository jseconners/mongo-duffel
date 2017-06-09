######################################################
#
#
# Written by James Conners (jseconners@gmail.com)
#
######################################################
ORIG_DIR=$( pwd )
cd $( dirname "${BASH_SOURCE[0]}" )
INST_DIR=$( pwd )


MONGO_ROOT='mongo_local'
MONGO_SRC=$MONGO_ROOT/src
MONGO_DAT=$MONGO_ROOT/dat
MONGO_LOG=$MONGO_ROOT/log
MONGO_PTH=$INST_DIR/$MONGO_SRC/bin


MONGO_URL='https://fastdl.mongodb.org'
MONGO_VER='3.4.4'
MONGO_OSV=(
    'debian 7 x64'
    'debian 8 x64'
    'rhel 6 x64'
    'rhel 7 x64'
    'suse 11 x64'
    'suse 12 x64'
    'ubuntu 12.04 x64'
    'ubuntu 14.04 x64'
    'ubuntu 16.04 x64'
    'ubuntu 16.04 ARM 64'
    'osx 10.7+ x64'
    'osx 10.7+ w/ssl x64'
)

MONGO_TAR=(
    "/linux/mongodb-linux-x86_64-debian71-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-debian81-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-rhel62-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-rhel70-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-suse11-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-suse12-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-ubuntu1204-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-ubuntu1404-$MONGO_VER.tgz"
    "/linux/mongodb-linux-x86_64-ubuntu1604-$MONGO_VER.tgz"
    "/linux/mongodb-linux-arm64-ubuntu1604-$MONGO_VER.tgz"
    "/osx/mongodb-osx-x86_64-$MONGO_VER.tgz"
    "/osx/mongodb-osx-ssl-x86_64-$MONGO_VER.tgz"
)

select_mongo() {
    PS3='Select OS version for mongodb install: '
    select opt in "${MONGO_OSV[@]}"
    do
        i=$((REPLY-1))
        if [ "x${MONGO_OSV[$i]}" != "x" ]; then
            MONGO_DOWNLOAD="${MONGO_URL}${MONGO_TAR[$i]}"
            MONGO_VERSION="${MONGO_OSV[$i]}"
            break
        fi
    done
}

install_mongo() {
    if [ ! -d "$MONGO_SRC" ] || [ ! "$(ls -A $MONGO_SRC)" ]; then
        print_info "No mongodb install found in $INST_DIR"
        select_mongo
        read -p "Download and install for $MONGO_VERSION? (y/n) " -n 1;

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "\nExiting without install"
            return
        fi;
        TARBALL=$( basename "$MONGO_DOWNLOAD" )
        DECOMPD=$( basename "$TARBALL" .tgz )

        echo "";
        mkdir -p "$MONGO_DAT" "$MONGO_LOG" &&
        curl -O "$MONGO_DOWNLOAD" &&

        echo -e "\n\nInstalling..."
        tar -zxvf "$TARBALL" > /dev/null 2>&1 &&
        mv "$DECOMPD" "$MONGO_SRC" &&
        rm "$TARBALL"
        echo -e "\nDone"
    else
        print_info "Local mongo already installed"
    fi
}

start_mongo() {
    LOCKFILE="$MONGO_DAT/mongod.lock"
    if [ -f "$LOCKFILE" ] && kill -0 $(cat "$LOCKFILE") 2>/dev/null; then
        print_info "Local mongodb is running"
    else
        print_info "Starting local mongodb"
        mongod --dbpath $MONGO_DAT --fork --logpath $MONGO_LOG/mongodb.log
    fi
}

stop_mongo() {
    LOCKFILE="$MONGO_DAT/mongod.lock"
    if [ -f "$LOCKFILE" ] && kill -0 $(cat "$LOCKFILE") 2>/dev/null; then
        print_info "Stopping mongo"
        kill -2 $(cat "$LOCKFILE")
    else
        print_info "No running mongo to stop"
    fi
}

add_path() {
    if [[ ! $PATH == $MONGO_PTH:* ]]; then
        print_info "Prepending local mongo binaries to path"
        export PATH=$MONGO_PTH:$PATH
    else
        print_info "Local mongo binary path already set"
    fi
}

remove_path() {
    if [[ $PATH == $MONGO_PTH:* ]]; then
        print_info "Removing local binaries from path"
        export PATH=${PATH#$MONGO_PTH:}
    else
        print_info "Local binaries already removed from path"
    fi
}

print_info() {
    # Print output in purple
    printf "\n\e[0;35m $1\e[0m"
}

echo "";
case "$1" in
    up)
        install_mongo
        add_path
        start_mongo
        ;;
    down)
        stop_mongo
        remove_path
        ;;
    *)
        echo "'$1' not understood"
      ;;
esac

# return to wherever you were
cd $ORIG_DIR
