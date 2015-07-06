
######### BEGIN EXAMPLE #########

# Set up stuff
HOST="http://testserver.com:3000/"

# Specify a bash-like array with the endpoints
REQUESTS=("api/route1" "api/route2" "api/route2/someOtherRoute" "api/route3/1")

# Specify a bash-like array with the body of each request
BODY=("" "{ \"name\": \"Pedro\" }" "{ \"lastname\": \"Valdivieso\" }" "")

# Specify a bash-like array with the methods of each request
HTTP_METHOD=("GET" "POST" "PUT" "DELETE")

# Specify a directory to store the files of each request
# and it will also be the name of the group
DIR="someDir"

######### END EXAMPLE #########

# Remove/create .apib file
rm -f $DIR.apib ; touch $DIR.apib

# Remove/create dir
rm -rf $DIR/ ; mkdir $DIR/

# Add title
echo "# Group $DIR" >> $DIR.apib

# Do the magic
I=1
for ((i=0;i<${#REQUESTS[@]};++i)); do # ${array[i]}

  echo "${REQUESTS[i]}"

  # Make API call
  if [ "${HTTP_METHOD[i]}" == "GET" ]; then
    curl \
    --trace tracefile \
    --header "Content-Type: application/json" \
    -request GET \
    $HOST${REQUESTS[i]}
  else
    curl \
    --trace tracefile \
    --header "Content-Type: application/json" \
    --request ${HTTP_METHOD[i]} \
    --data-binary "${BODY[i]}" \
    $HOST${REQUESTS[i]}
  fi

  # Parse URL to get a file name
  REQUEST_SPLIT=$(echo ${REQUESTS[i]} | tr "/" "\n")
  FILENAME=" "
  for x in $REQUEST_SPLIT
  do
    FILENAME="$(echo $FILENAME$x)"
  done

  # Pipe tracefile with curl-trace-parser command
  cat tracefile | curl-trace-parser --blueprint > $DIR/$FILENAME.apib

  # Delete tracefile
  rm -f tracefile

  # Remove first line and add another two for later replacement
  sed -i "/#/d" $DIR/$FILENAME.apib ; sed -i "1s|^|## Replace this $I [/${REQUESTS[i]}]\n### Replace this again $I [${HTTP_METHOD[i]}]\n|" $DIR/$FILENAME.apib

  # Append to $DIR.apib file
  echo "" >> $DIR.apib
  cat $DIR/$FILENAME.apib >> $DIR.apib

  I=$((I+1))
done

echo ""
echo "DONE"
