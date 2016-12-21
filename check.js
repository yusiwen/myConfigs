#!/usr/bin/env node

const https = require('https');

var repos = [
  'atom/atom', 'adobe/brackets', 'Microsoft/vscode',
  'git-for-windows/git', 'gogits/gogs',
  'kovidgoyal/calibre', 'keeweb/keeweb',
  'tagspaces/tagspaces', 'appetizermonster/hain',
  'shadowsocks/ShadowsocksX-NG', 'shadowsocks/shadowsocks-qt5',
  'felixhageloh/uebersicht', 'evolus/pencil',
  'brrd/Abricotine', 'Laverna/laverna',
  'electron/electron', 'electron/electron-api-demos',
  'cryptomator/cryptomator', 'wallabag/wallabag'
];

for (var i = 0; i < repos.length; i++) {
  (function (repo) {
    var url = '/repos/' + repo + '/releases/latest';
    var option = {
      hostname: 'api.github.com',
      port: 443,
      path: url,
      method: 'GET',
      headers: {
        'User-Agent': 'request'
      }
    };

    var req = https.request(option, (res) => {
      var statusCode = res.statusCode;

      var resp = '';
      res.on('data', (d) => {
        resp += d;
      });
      res.on('end', () => {
        if (statusCode == '200') {
          var json = JSON.parse(resp);
          var tagName = json['tag_name'];
          var pubDate = json['published_at'];
          console.log(repo + ':\n\t' + tagName + ' (' + pubDate.replace(/T/, ' ').replace(/\..+/, '') + ')');
        } else if (statusCode == '404') {
          getLatestTag(repo);
        } else {
          console.log(repo + ':\n\tError to retrieve data: ' + statusCode);
        }
      });
    });
    req.end();

    req.on('error', (e) => {
      console.error(e);
    });
  })(repos[i]);
}

function getLatestTag(repo) {
  var url = '/repos/' + repo + '/tags';
  var option = {
    hostname: 'api.github.com',
    port: 443,
    path: url,
    method: 'GET',
    headers: {
      'User-Agent': 'request'
    }
  };

  var req = https.request(option, (res) => {
    var statusCode = res.statusCode;

    var resp = '';
    res.on('data', (d) => {
      resp += d;
    });
    res.on('end', () => {
      if (statusCode == '200') {
        var json = JSON.parse(resp);
        json.sort((a, b) => {
          var p1 = a.name,
            p2 = b.name;
          if (p1.charAt(0) == 'v')
            p1 = p1.substr(1);
          if (p2.charAt(0) == 'v')
            p2 = p2.substr(1);

          return versionCompare(p2, p1);
        });
        console.log(repo + ':\n\t' + json[0].name);
      } else {
        console.log(repo + ':\n\tError to retrieve data: ' + statusCode);
      }
    });
  });
  req.end();

  req.on('error', (e) => {
    console.error(e);
  });
}

function versionCompare(v1, v2, options) {
  var lexicographical = options && options.lexicographical,
    zeroExtend = options && options.zeroExtend,
    v1parts = v1.split('.'),
    v2parts = v2.split('.');

  function isValidPart(x) {
    return (lexicographical ? /^\d+[A-Za-z]*$/ : /^\d+$/).test(x);
  }

  if (!v1parts.every(isValidPart) || !v2parts.every(isValidPart)) {
    return NaN;
  }

  if (zeroExtend) {
    while (v1parts.length < v2parts.length) v1parts.push("0");
    while (v2parts.length < v1parts.length) v2parts.push("0");
  }

  if (!lexicographical) {
    v1parts = v1parts.map(Number);
    v2parts = v2parts.map(Number);
  }

  for (var i = 0; i < v1parts.length; ++i) {
    if (v2parts.length == i) {
      return 1;
    }

    if (v1parts[i] == v2parts[i]) {
      continue;
    } else if (v1parts[i] > v2parts[i]) {
      return 1;
    } else {
      return -1;
    }
  }

  if (v1parts.length != v2parts.length) {
    return -1;
  }

  return 0;
}
