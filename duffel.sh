######################################################
#
#
# Written by James Conners (jseconners@gmail.com)
#
######################################################

MDFL_ORIG_DIR=$( pwd )
cd $( dirname "${BASH_SOURCE[0]}" )
MDFL_INST_DIR=$( pwd )


MDFL_MONGO_ROOT='mongo_local'
MDFL_MONGO_SRC=$MDFL_MONGO_ROOT/src
MDFL_MONGO_DAT=$MDFL_MONGO_ROOT/dat
MDFL_MONGO_LOG=$MDFL_MONGO_ROOT/log
MDFL_MONGO_PTH=$MDFL_INST_DIR/$MDFL_MONGO_SRC/bin
MDFL_MONGO_ARC='dataduffel.tar.gz'

MDFL_MONGO_URL='https://fastdl.mongodb.org'
MDFL_MONGO_VER='3.4.4'
MDFL_MONGO_OSV=(
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

MDFL_MONGO_TAR=(
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

MDFL_select_mongo() {
    PS3='Select OS version for mongodb install: '
    select opt in "${MDFL_MONGO_OSV[@]}"
    do
        i=$((REPLY-1))
        if [ "x${MDFL_MONGO_OSV[$i]}" != "x" ]; then
            MDFL_MONGO_DOWNLOAD="${MDFL_MONGO_URL}${MDFL_MONGO_TAR[$i]}"
            MDFL_MONGO_VERSION="${MDFL_MONGO_OSV[$i]}"
            break
        fi
    done
}

MDFL_check_install() {
    if [ -d "$MDFL_MONGO_SRC" ] && [ "$(ls -A $MDFL_MONGO_SRC)" ]; then
        MDFL_INSTALL_STATUS='installed'
    else
        unset MDFL_INSTALL_STATUS
    fi
}

MDFL_check_server() {
    MDFL_LOCKFILE="$MDFL_MONGO_DAT/mongod.lock"
    if [ -f "$MDFL_LOCKFILE" ] && kill -0 $(cat "$MDFL_LOCKFILE") > /dev/null 2>&1; then
        MDFL_SERVER_STATUS='running'
    else
        unset MDFL_SERVER_STATUS
    fi
}

MDFL_check_path() {
    if [[ $PATH == $MDFL_MONGO_PTH:* ]]; then
        MDFL_PATH_STATUS='set'
    else
        unset MDFL_PATH_STATUS
    fi
}

MDFL_check_data() {
    if [ -f "$MDFL_MONGO_ARC" ]; then
        MDFL_DATA_STATUS='exists'
    else
        unset MDFL_DATA_STATUS
    fi
}

MDFL_install() {
    MDFL_select_mongo
    echo "";
    if MDFL_ask "Download and install for $MDFL_MONGO_VERSION?" N; then
        MDFL_TARBALL=$( basename "$MDFL_MONGO_DOWNLOAD" )
        MDFL_DECOMPD=$( basename "$MDFL_TARBALL" .tgz )

        echo "";
        mkdir -p "$MDFL_MONGO_DAT" "$MDFL_MONGO_LOG" &&
        curl -O "$MDFL_MONGO_DOWNLOAD" &&

        MDFL_print_info "Installing local mongodb..."
        tar -zxvf "$MDFL_TARBALL" > /dev/null 2>&1 &&
        mv "$MDFL_DECOMPD" "$MDFL_MONGO_SRC" &&
        rm "$MDFL_TARBALL"
    else
        MDFL_print_info "Exiting without install"
    fi
    MDFL_status
}

MDFL_start() {
    mongod --dbpath $MDFL_MONGO_DAT --fork --logpath $MDFL_MONGO_LOG/mongodb.log
    MDFL_status
}

MDFL_stop() {
    kill -2 $(cat "$MDFL_LOCKFILE")
    MDFL_status
}

MDFL_add_path() {
    export PATH=$MDFL_MONGO_PTH:$PATH
    MDFL_status
}

MDFL_remove_path() {
    export PATH=${PATH#$MDFL_MONGO_PTH:}
    MDFL_status
}

MDFL_unpack_data() {
    [ "$(ls -A $MDFL_MONGO_DAT)" ] && rm -r "$MDFL_MONGO_DAT"/*
    tar xzf "$MDFL_MONGO_ARC" -C "$MDFL_MONGO_DAT"
    MDFL_status
}

MDFL_pack_data() {
    tar czf "$MDFL_MONGO_ARC" -C "$MDFL_MONGO_DAT" .
    MDFL_status
}

MDFL_print_info() {
    # Print output in purple
    printf "\e[0;35m$1\e[0m\n"
}

# https://gist.github.com/davejamesmiller/1965569
MDFL_ask() {
    # https://djm.me/ask
    local prompt default REPLY
    while true; do
        if [ "${2:-}" = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi
        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "
        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read REPLY </dev/tty
        # Default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi
        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

MDFL_status() {
    MDFL_check_install
    MDFL_check_server
    MDFL_check_path
    MDFL_check_data
}


MDFL_up() {
    # install local mongodb if not found
    if [ "$MDFL_INSTALL_STATUS" = 'installed' ]; then
        MDFL_print_info "Local mongodb installed"
    else
        MDFL_print_info "No local mongodb install found"
        echo "";
        MDFL_install
    fi

    # prefix local binaries to PATH if not already
    if [ "$MDFL_PATH_STATUS" = 'set' ]; then
        MDFL_print_info "Local binaries already in path"
    else
        MDFL_print_info "Adding local binaries to path"
        MDFL_add_path
    fi

    # if data duffel exits, prompt to overwrite data directory with it
    if [ "$MDFL_DATA_STATUS" = 'exists' ]; then
        if MDFL_ask "Overwite data dir with $MDFL_MONGO_ARC?" N; then
            if [ "$MDFL_SERVER_STATUS" = 'running' ]; then
                MDFL_print_info "Stopping server"
                MDFL_stop
            fi
            MDFL_print_info "Unpacking data..."
            MDFL_unpack_data
            MDFL_print_info "Done"
        fi
    fi

    # check server status and start if necessary
    if [ "$MDFL_SERVER_STATUS" = 'running' ]; then
        MDFL_print_info "Local mongodb is running"
    else
        MDFL_print_info "Starting local mongodb"
        MDFL_start
    fi
}

MDFL_down() {
    # remove local binaries from path if necessary
    if [ "$MDFL_PATH_STATUS" = 'set' ]; then
        MDFL_print_info "Removing local binaries from path"
        MDFL_remove_path
    else
        MDFL_print_info "Local binaries already removed from path"
    fi

    # stop server if it's running
    if [ "$MDFL_SERVER_STATUS" = 'running' ]; then
        MDFL_print_info "Stopping server"
        MDFL_stop
    else
        MDFL_print_info "Server not running"
    fi

    # prompt to pack up data directory
    if MDFL_ask "Pack up data directory to $MDFL_MONGO_ARC?" N; then
        MDFL_print_info "Packing it up..."
        MDFL_pack_data
        MDFL_print_info "Done"
    fi
}



echo "";
case "$1" in
    up)
        MDFL_status
        MDFL_up;;
    down)
        MDFL_status
        MDFL_down;;
    *)
        echo "'$1' not understood";;
esac

# return to wherever you were
cd $MDFL_ORIG_DIR
