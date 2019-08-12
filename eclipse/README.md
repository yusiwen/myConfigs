# Eclipse Setup

## Location & Startup

Set `$IDE_HOME` environment variable to your home directory of all IDEs, such as `/opt/ide`.

Install eclipse in `$IDE_HOME/eclipse` directory.

Change directory name to version name, such as `$IDE_HOME/eclipse/eclipse-java-luna-SR2`.

Use `ec.py` script to start eclipse.

## Upgrade components

1. Mylyn latest version

    Update site url: http://download.eclipse.org/mylyn/releases/latest

1. EGit latest version

    Update site url: http://download.eclipse.org/egit/updates

1. m2e latest version

    Update site url: http://download.eclipse.org/technology/m2e/releases

1. subclipse

    Update site url: http://subclipse.tigris.org/update_1.10.x

1. eclipse-color-theme

    Update site url: http://eclipse-color-theme.github.com/update

1. Jeeeyul's theme

    Update site url: http://eclipse.jeeeyul.net/update/

1. EditBox

    Update site url: http://editbox.sourceforge.net/updates

## Subclipse JavaHL library

```sh
sudo apt-get install libsvn-java
```

Tell Java where to find the JavaHL library is to specify the following when starting the JVM:

```sh
-Djava.library.path=/usr/lib/x86_64-linux-gnu/jni
```

For more details, please check out this subclipse official [wiki page](http://subclipse.tigris.org/wiki/JavaHL#head-bb1dd50f9ec2f0d8c32246430c00e237d27a04fe)
