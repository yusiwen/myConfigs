# Oracle Instant Client

## Installation

1. Download the desired Instant Client ZIP files. All installations require the Basic or Basic Light package.

1. Unzip the packages into a single directory such as `/opt/oracle/instantclient_12_2` that is accessible to your application. For example:

```shell
  cd /opt/oracle
  unzip instantclient-basic-linux.x64-12.2.0.1.0.zip
```

1. Create the appropriate links for the version of Instant Client, if the links do not exist. For example:

```shell
  cd /opt/oracle/instantclient_12_2
  ln -s libclntsh.so.12.1 libclntsh.so
  ln -s libocci.so.12.1 libocci.so
```

1. Install the libaio package. This is called `libaio1` on some Linux distributions.

For example, on Oracle Linux, run:

```shell
  sudo yum install libaio
```

1. If Instant Client is the only Oracle Software installed on this system then update the runtime link path, for example:

```shell
  sudo sh -c "echo /opt/oracle/instantclient_12_2 > \
      /etc/ld.so.conf.d/oracle-instantclient.conf"
  sudo ldconfig
```

Alternatively, set the `LD_LIBRARY_PATH` environment variable prior to running applications. For example:

```shell
  export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2:$LD_LIBRARY_PATH
```

The variable can optionally be added to configuration files such as `~/.bash_profile` and to application configuration files such as `/etc/sysconfig/httpd`.

1. If you intend to co-locate optional Oracle configuration files such as `tnsnames.ora`, `sqlnet.ora`, `ldap.ora`, or `oraaccess.xml` with Instant Client, then create a `network/admin` subdirectory. For example:

```shell
  mkdir -p /opt/oracle/instantclient_12_2/network/admin
```

This is the default Oracle configuration directory for applications linked with this Instant Client.

Alternatively, Oracle configuration files can be put in another, accessible directory. Then set the environment variable `TNS_ADMIN` to that directory name.

1. To use binaries such as sqlplus from the SQL*Plus package, unzip the package to the same directory as the Basic package and then update your `PATH` environment variable, for example:

```shell
  export PATH=/opt/oracle/instantclient_12_2:$PATH
```

1. Start your application.

## Oracle Instant Client Library Path Configurations on Ubuntu

1. Copy `ora.conf` to `/etc/ld.so.conf.d/`
2. run `sudo ldconfig`
