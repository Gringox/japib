# JAPIB


### Usage
 ./japib.sh file.json

### Description:
Creates apib file from a json file

### Example:
    {
        "host": "http://127.0.0.1:3000/v1",
        "group": "Users",
        "headers": [
            {
                "name": "token",
                "value": "qPrGcl7Hs6LB3UARQ0DeSVDIJwLonbtv4aLNX1cJhsFFPx4XNCnkUDlAFhVtwznk"
            },
            {
                "name": "Content-Type",
                "value": "application/json"
            }
        ],
        "requests": [
            { 
                "route": "/users/me",
                "method": "GET",
                "body": {},
                "collection": "ME",
                "action": "List One"
            },
            { 
                "route": "/users/me",
                "method": "PUT",
                "body": {
                    "email": "email",
                    "password": "123456"
                },
                "collection": "",
                "action": "UPDATE"
           }
        ]
    }
