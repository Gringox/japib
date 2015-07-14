#!/bin/bash

#
#   JAPIB: JSON to APIB script
#
#   Version: v0.1
#
#   Authors:
#       Pedro Valdivieso
#       Javier Arguello
#
#   Dependencies:
#       libcurl -> apt-get install libcurl
#       jq -> apt-get install jq
#       curl-trace-parser -> npm install -g curl-trace-parser
#



api() {
    # Make API call
    if [ "$HTTP_METHOD" = "GET" ]; then
        CURL="curl --trace tracefile $HEADERS --request GET $HOST$ROUTE -d '$BODY'"
        eval $CURL >> /dev/null
    else
        CURL="curl --trace tracefile $HEADERS --request $HTTP_METHOD $HOST$ROUTE -d '$BODY'"
        eval $CURL >> /dev/null
    fi


    if [ -n "$COLLECTION" ]; then
        echo "## $COLLECTION [$ROUTE]" >> $DIR/$GROUP.apib
    fi  

    echo "### $ACTION [$HTTP_METHOD]" >> $DIR/$GROUP.apib
    # Pipe tracefile with curl-trace-parser command
    cat tracefile | curl-trace-parser --blueprint | tail -n +2  >> $DIR/$GROUP.apib

    # Delete tracefile
    rm -f tracefile
}


headers(){
    
    # Get Request's headers
    HEADERS=""
    i=0;
    HEADER=`cat $INPUT | jq ".headers[$i]"`
    while [ "$HEADER" != null ]
    do
        NAME=`cat $INPUT | jq ".headers[$i].name" | cut -d '"' -f 2` 
        VALUE=`cat $INPUT | jq ".headers[$i].value" | cut -d '"' -f 2` 

        HEADERS="$HEADERS --header '$NAME: $VALUE'"
        i=$((i + 1))
        HEADER=`cat $INPUT | jq ".headers[$i]"`
    done
}

requests() {
    i=0;
    REQUEST=`cat $INPUT | jq ".requests[$i]"`

    while [ "$REQUEST" != null ]
    do
        HTTP_METHOD=`cat $INPUT |jq ".requests[$i].method" | cut -d '"' -f 2`
        ROUTE=`cat $INPUT | jq ".requests[$i].route" | cut -d '"' -f 2` 
        BODY=`cat $INPUT | jq ".requests[$i].body"` 
        COLLECTION=`cat $INPUT | jq ".requests[$i].collection" | cut -d '"' -f 2` 
        ACTION=`cat $INPUT | jq ".requests[$i].action" | cut -d '"' -f 2` 
           
        # Call API 
        api

        i=$((i + 1))
        REQUEST=`cat $INPUT | jq ".requests[$i]"`
    done;
}

usage() {
    echo "\tUsage: ./japib file"
    exit 1
}

#
#   Main
#

# Check Args
if [ "$#" -ne 1 ]; then
    echo "Error: Illegal number of parameters"
    usage
fi

if [ -f $1 ]; then
    echo "JAPIB: Creating doc..."
else
    echo "Error: $1 is not a file"
    usage
    exit 1
fi


INPUT=$1
HOST=`cat $INPUT | jq '.host' | cut -d '"' -f 2`
GROUP=`cat $INPUT | jq '.group' | cut -d '"' -f 2`
DIR='.'

# Write Resource collection
echo "# Group $GROUP" > $DIR/$GROUP.apib

headers
requests

exit 0
