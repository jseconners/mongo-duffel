
######################################################
#
#  ex: source install.sh
#
######################################################

MDFL_ORIG_DIR=$( pwd )
cd $( dirname "${BASH_SOURCE[0]}" )
MDFL_INST_DIR=$( pwd )
MDFL_SRC='src'

while true; do
	read -p "Specify directory to install to: ";
    MDFL_DIR=${REPLY%/}
    MDFL_DIR=${MDFL_DIR/\~/$HOME}

    if [ "x$MDFL_DIR" = "x" ]; then
        continue
    fi

    if [ ! -d "$MDFL_DIR" ]; then
        read -p "($MDFL_DIR) doesn't exist. Create (y/n)? " -n 1;
        echo "";
        if [[ $REPLY =~ ^[Yy]$ ]] && mkdir -p $MDFL_DIR; then
            break
        else
            echo "Exiting with install"
            return
        fi
    else
        break
    fi

done

read -p "Install into $MDFL_DIR (y/n)? " -n 1;
echo "";
if [[ $REPLY =~ ^[Yy]$ ]] && cp -r $MDFL_SRC/. $MDFL_DIR/; then
    echo "mongo-duffel installed in $MDFL_DIR"
fi

cd $MDFL_ORIG_DIR
