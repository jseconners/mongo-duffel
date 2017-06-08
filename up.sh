
ORIG_DIR=$( pwd )
cd $( dirname "${BASH_SOURCE[0]}" )
INST_DIR=$( pwd )


MONGO_ROOT='mongo_local'
MONGO_SRC=$MONGO_ROOT/src
MONGO_DAT=$MONGO_ROOT/dat
MONGO_LOG=$MONGO_ROOT/log

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

function confirm() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo "$REPLY" | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

# install mongodb
if [ ! -f "$MONGO_SRC/bin/mongod" ]; then
    select_mongo
    if [[ "no" == $(confirm "Install for $MONGO_VERSION?") ]]
    then
        echo "Exiting."
        return
    fi

    TARBALL=$( basename "$MONGO_DOWNLOAD" )
    DECOMPD=$( basename "$TARBALL" .tgz )

    mkdir -p "$MONGO_DAT" "$MONGO_LOG" &&
    curl -O "$MONGO_DOWNLOAD" &&
    tar -zxvf "$TARBALL" &&
    mv "$DECOMPD" "$MONGO_SRC" &&
    rm "$TARBALL"
else
    # 1. check for lock file
    # 2. check for altered path env var
fi

chmod -R 777 $MONGO_DATDIR

export OLDPATH=$PATH
export PATH=$MONGO_INCDIR/bin:$PATH

mongod --dbpath $MONGO_DATDIR --fork --logpath $MONGO_LOGDIR/mongodb.log

echo -e "\nReturning from m101p root dir..."
cd $CURRDIR
echo -e "\nDone!\n"
