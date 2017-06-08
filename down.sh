#
#

# change into root dir and set things up
echo -e "\nEntering m101p root dir to tear things down..."
CURRDIR=$( pwd )
cd $( dirname "${BASH_SOURCE[0]}" )
ROOTDIR=$( pwd )

MONGO_INCDIR=$ROOTDIR/mongodb
MONGO_DATDIR='mongodb_data'
MONGO_DATARC='mongodb_data.tar.gz'

# undo modified path for local mongodb
if [ -n "$OLDPATH" ]; then
    echo "Unsetting modified path..."
    export PATH=$OLDPATH
    unset OLDPATH
else
    echo "No modified path var. Doing nothing..."
fi

# kill running mongo process
echo -e "\nShutting down mongod server..."
if [ -f $MONGO_DATDIR/mongod.lock ]; then
    kill -2 $( cat $MONGO_DATDIR/mongod.lock )
else
    echo "Mongod not running"
fi

# archive current data
echo -e "\nArchiving current data directory..."
tar -zcvf $MONGO_DATARC $MONGO_DATDIR

# deactivate virtualenv
if [ -n "$VIRTUAL_ENV" ]; then
    echo "Deactivating virtual env..."
    deactivate
else
    echo "No active virtual env..."
fi

echo -e "\nReturning from m101p root dir..."
cd $CURRDIR
echo -e "\nDone!\n"
