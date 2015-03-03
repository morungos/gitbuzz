Gitbuzz
=======

A Github activity visualization app for teams and groups

Written using:
 * angular
 * angular-ui
 * d3
 * mongodb

To start it:

```shell
$ npm install
$ bower install
$ gulp serve
```

You'll also need a config file that looks a bit like this:

The long hexadecimal string is the token assigned by Github for
this application. Get one from Github under Settings >
Applications > Personal access tokens. 

```javascript
{
  "github": {
    "settings": {
      "hostname": "api.github.com",
      "port": 443,
      "headers": {
        "User-Agent": "morungos",
        "Authorization": "token 0a1b2c3d4e5f0a1b2c3d4e5f0a1b2c3d4e5f0a1b"
      }
    },
    "users": [
      { "id" : "morungos", "teams" : ["team1"]},
      { "id" : "user1", "teams" : ["team1"]},
      { "id" : "user2", "teams" : ["team1"]},
      { "id" : "user3", "teams" : ["team2"]},
      ...
    ]
  }
}
```

Todo:

 * Testing - a lot
 * Commenting - almost as much
