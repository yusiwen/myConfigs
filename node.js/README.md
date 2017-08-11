# Node.js

## npm

Using [Taobao mirror](https://npm.taobao.org/):

```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

or

```
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

```
yarn config set registry https://registry.npm.taobao.org
```

See [here](https://cnodejs.org/topic/57ff0541487e1e4578afb48d)

## Advanced steps

```
$ npm set registry https://registry.npm.taobao.org # 注册模块镜像
$ npm set disturl https://npm.taobao.org/dist # node-gyp 编译依赖的 node 源码镜像

## 以下选择添加
$ npm set chromedriver_cdnurl http://cdn.npm.taobao.org/dist/chromedriver # chromedriver 二进制包镜像
$ npm set operadriver_cdnurl http://cdn.npm.taobao.org/dist/operadriver # operadriver 二进制包镜像
$ npm set phantomjs_cdnurl http://cdn.npm.taobao.org/dist/phantomjs # phantomjs 二进制包镜像
$ npm set fse_binary_host_mirror https://npm.taobao.org/mirrors/fsevents # fsevents 二进制包
$ npm set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass # node-sass 二进制包镜像
$ npm set electron_mirror http://cdn.npm.taobao.org/dist/electron/ # electron 二进制包镜像
```

See [在中国，安装 & 升级 npm 依赖的正确方法](https://sebastianblade.com/the-truly-way-to-install-upgrade-npm-dependency-in-china/)
