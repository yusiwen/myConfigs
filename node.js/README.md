# Node.js

## npm

Using [Taobao mirror](https://npm.taobao.org/):

```sh
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

or

```sh
alias cnpm="npm --registry=https://registry.npm.taobao.org \
--cache=$HOME/.npm/.cache/cnpm \
--disturl=https://npm.taobao.org/dist \
--userconfig=$HOME/.cnpmrc"

# Or alias it in .bashrc or .zshrc
$ echo '\n#alias for cnpm\nalias cnpm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.cnpmrc"' >> ~/.zshrc && source ~/.zshrc
```

## yarn

Using Taobao mirror:

```sh
yarn config set registry https://registry.npm.taobao.org
```

See [here](https://cnodejs.org/topic/57ff0541487e1e4578afb48d)

## Advanced steps

```sh
# 注册模块镜像
npm set registry https://registry.npm.taobao.org
# node-gyp 编译依赖的 node 源码镜像
npm set disturl https://npm.taobao.org/disturl

## 以下选择添加
# chromedriver 二进制包镜像
npm set chromedriver_cdnurl https://npm.taobao.org/mirrors/chromedriver/
# operadriver 二进制包镜像
npm set operadriver_cdnurl https://npm.taobao.org/mirrors/operadriver/
# phantomjs 二进制包镜像
npm set phantomjs_cdnurl https://npm.taobao.org/mirrors/phantomjs/
# fsevents 二进制包
npm set fse_binary_host_mirror https://npm.taobao.org/mirrors/fsevents/
# node-sass 二进制包镜像
npm set sass_binary_site https://npm.taobao.org/mirrors/node-sass/
# electron 二进制包镜像
npm set electron_mirror https://npm.taobao.org/mirrors/electron/
```

See [在中国，安装 & 升级 npm 依赖的正确方法](https://sebastianblade.com/the-truly-way-to-install-upgrade-npm-dependency-in-china/)
See [NodeJS使用淘宝npm镜像站的各种姿势](https://segmentfault.com/a/1190000008410558)
