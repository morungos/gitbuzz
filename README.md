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

```javascript
{
  "github": {
    "settings": {
      "hostname": "api.github.com",
      "port": 443,
      "headers": {
        "User-Agent": "morungos",
        "Authorization": "token ..."
      }
    },
    "users": [
      { "id" : "morungos", "teams" : ["ferrettilab"]},
      ...
    ]
  }
}
```

Todo:

 * Testing - a lot
 * Commenting - almost as much
