//console.log('Hello, world!');

const https = require('https');

var repos = [{
    name: 'atom',
    repo: 'atom/atom'
  },
  {
    name: 'brackets.io',
    repo: 'adobe/brackets'
  },
  {
    name: 'git-for-windows',
    repo: 'git-for-windows/git'
  },
  {
    name: 'calibre',
    repo: 'kovidgoyal/calibre'
  }, {
    name: 'keeweb',
    repo: 'keeweb/keeweb'
  }, {
    name: 'tagspaces',
    repo: 'tagspaces/tagspaces'
  }, {
    name: 'hain',
    repo: 'appetizermonster/hain'
  }, {
    name: 'ShadowsocksX-NG',
    repo: 'shadowsocks/ShadowsocksX-NG'
  }, {
    name: 'shadowsocks-qt5',
    repo: 'shadowsocks/shadowsocks-qt5'
  }];

for (var i = 0; i < repos.length; i++) {
  (function (repo) {
    var url = '/repos/' + repo.repo + '/releases/latest';
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
          console.log(repo.name + ':\n\t' + tagName + '\n\t' + pubDate.replace(/T/, ' ').replace(/\..+/, ''));
        } else {
          console.log(repo.name + ':\n\tError to retrieve data: ' + statusCode);
        }
      });
    });
    req.end();

    req.on('error', (e) => {
      console.error(e);
    });
  })(repos[i]);
}
