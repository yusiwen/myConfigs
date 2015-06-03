Download / Install
==================

Requirements
------------

Before beginning the installation, first confirm that you have met the
following requirements.

-   [Java Development
    Kit](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
    1.7 or greater
-   [Vim](http://www.vim.org/download.php) 7.1 or greater
-   [Eclipse eclipse\_version](http://eclipse.org/downloads/index.php)
-   Mac and Linux users must also have make and gcc installed.

    **Minimum Vim Settings**: In order for eclim to function properly,
    there is a minimum set of vim options that must be enabled in your
    vimrc file (:h vimrc).

    -   **set nocompatible**

        Execute :h 'compatible' for more info. You can confirm that
        compatibliity is turned off by executing the following in vim:

        ``` {.sourceCode .vim}
        :echo &compatible
        ```

        Which should output '0', but if not, then add the following to
        your \~/.vimrc files (\_vimrc on Windows):

        ``` {.sourceCode .vim}
        set nocompatible
        ```

    -   **filetype plugin on**

        Execute :h filetype-plugin-on for more info. You can confirm
        that file type plugins are enabled by executing the following:

        ``` {.sourceCode .vim}
        :filetype
        ```

        Which should output 'filetype detection:ON plugin:ON indent:ON',
        showing at least 'ON' for 'detection' and 'plugin', but if not,
        then update your \~/.vimrc (\_vimrc on Windows) to include:

        ``` {.sourceCode .vim}
        filetype plugin indent on
        ```

Download
--------

You can find the official eclim installer on eclim's sourceforge
[downloads page](https://sourceforge.net/projects/eclim/files/eclim/):

-   jar

### Third Party Packages

As an alternative to the official installer, there are also some
packages maintained by third parties:

-   **Arch:** [aur (eclim)](https://aur.archlinux.org/packages/eclim/),
    [aur (eclim-git)](https://aur.archlinux.org/packages/eclim-git/)

Installing / Upgrading
----------------------

Eclim can be installed a few different ways depending on your preference
and environment:

-   Graphical Installer \<installer\>
-   Unattended (automated) Installer \<installer-automated\>
-   Build from source \<install-source\>
-   Install on a headless server \<install-headless\>

### Graphical Installer

#### Step 1: Run the installer

> **note**
>
> If you have eclipse running, please close it prior to starting the
> installation procedure.

-   **First download the installer:** jar
-   **Next run the installer:**

    ``` {.sourceCode .bash}
    $ java -jar eclim_eclim_release.jar
    ```

    Windows and OSX users should be able to simply double click on the
    jar file to start the installer.

    After the installer starts up, simply follow the steps in the wizard
    to install eclim.

    If your machine is behind a proxy, take a look at the instructions
    for running the installer behind a proxy \<installer-proxy\>.

    If you encounter an error running the installer, then consult the
    known potential \<installer-issues\> issues below.

#### Step 2: Test the installation

To test eclim you first need to start the eclim daemon. How you start
the daemon will depend on how you intend to use eclim.

> **note**
>
> More info on running the eclim daemon can be found in the eclimd
> \</eclimd\> docs.

If you plan on using eclim along with the eclipse gui, then simply start
eclipse and open the eclimd view:

Window --\> Show View --\> Other --\> Eclim --\> eclimd

By default the eclimd view will also be auto opened when you open a file
using:

Open With --\> Vim

If you plan on using eclim without the eclipse gui, then:

-   start the eclimd server.
    -   **Linux / Mac / BSD (and other unix based systems)**: To start
        eclimd from linux, simply execute the eclimd script found in
        your eclipse root directory:

            $ $ECLIPSE_HOME/eclimd

    -   **Windows**: The easiest way to start eclimd in windows is to
        double click on the eclimd.bat file found in your eclipse root
        directory:

            %ECLIPSE_HOME%/eclimd.bat

Once you have the eclim daemon (headed or headless) running, you can
then test eclim:

-   open a vim window and issue the command, :PingEclim. The result of
    executing this command should be the eclim and eclipse version
    echoed to the bottom of your Vim window. If however, you receive
    `unable to connect to eclimd - connect: Connection refused`, or
    something similar, then your eclimd server is not running or
    something is preventing eclim from connecting to it. If you receive
    this or any other errors you can start by first examining the eclimd
    output to see if it gives any info as to what went wrong. If at this
    point you are unsure how to proceed you can view the
    troubleshooting guide \<troubleshooting\> or feel free to post your
    issue on the [eclim-user](http://groups.google.com/group/eclim-user)
    mailing list.

    Example of a successful ping:

    ![image][1]

    Example of a failed ping:

    ![image][2]

-   Regardless of the ping result, you can also verify your vim settings
    using the command **:EclimValidate**. This will check various
    settings and options and report any problems. If all is ok you will
    receive the following message:

        Result: OK, required settings are valid.

#### Running The Installer Behind a Proxy

If you are behind a proxy, you may need to run the installer like so (be
sure to take a look at the related faq \<eclim\_proxy\> as well):

``` {.sourceCode .bash}
$ java -Dhttp.proxyHost=my.proxy -Dhttp.proxyPort=8080 -jar eclim_eclim_release.jar
```

If your proxy requires authentication, you'll need to supply the
`-Dhttp.proxyUser` and `-Dhttp.proxyPassword` properties as well.

You can also try the following which may be able to use your system
proxy settings:

``` {.sourceCode .bash}
$ java -Djava.net.useSystemProxies=true -jar eclim_eclim_release.jar
```

#### Potential Installation Issues

In some rare cases you might encounter one of the following errors:

1.  Any exception which denotes usage of gcj. :

        java.lang.NullPointerException
          at org.pietschy.wizard.HTMLPane.updateEditorColor(Unknown Source)
          at org.pietschy.wizard.HTMLPane.setEditorKit(Unknown Source)
          at javax.swing.JEditorPane.getEditorKit(libgcj.so.90)
          ...

    Gcj (GNU Compile for Java), is not currently supported. If you
    receive any error which references libgcj, then gcj is your current
    default jvm. So, you'll need to install the openjdk or a jdk from
    oracle to resolve the installation error.

2.  java.lang.IncompatibleClassChangeError
          at org.formic.ant.logger.Log4jLogger.printMessage(Log4jLogger.java:51)
          ...

    This is most likely caused by an incompatible version of log4j
    installed in your jave ext.dirs. To combat this you can run the
    installer like so:

        $ java -Djava.ext.dirs -jar eclim_eclim_release.jar

If you encounter an error not covered here, then please report it to the
[eclimuuser](http://groups.google.com/group/eclim-user) mailing list.

### Unattended (automated) install

As of eclim 1.5.6 the eclim installer supports the ability to run an
automated install without launching the installer gui. Simply run the
installer as shown below, supplying the location of your vim files and
your eclipse install via system properties:

``` {.sourceCode .bash}
$ java \
  -Dvim.files=$HOME/.vim \
  -Declipse.home=/opt/eclipse \
  -jar eclim_eclim_release.jar install
```

Please note that when using this install method, the installer will only
install eclim features whose third party dependecies are already present
in your eclipse installation. So before installing eclim, you must make
sure that you've already installed the necessary dependencies (for a
full list of dependencies, you can reference eclim's [installer
dependencies](https://github.com/ervandew/eclim/blob/master/org.eclim.installer/build/resources/dependencies.xml)
file).

**Required Properties:**

-   **eclipse.home** - The absolute path to your eclipse installation.
-   **vim.files** (or **vim.skip=true**) - The absolute path to your vim
    files directory. Or if you want to omit the installation of the vim
    files (emacs-eclim users for example) you can supply
    `-Dvim.skip=true` instead.

### Building from source

### Installing on a headless server

The eclim daemon supports running both inside of the eclipse gui and as
a "headless" non-gui server. However, even in the headless mode, eclipse
still requires a running X server to function. If you are running eclim
on a desktop then this isn't a problem, but some users would like to run
the eclim daemon on a truly headless server. To achieve this, you can
make use of X.Org's Xvfb server.

> **note**
>
> This guide uses the Ubuntu server distribution to illustrate the
> process of setting up a headless server, but you should be able to run
> Xvfb on the distro of your choice by translating the package names
> used here to your distro's equivalents.

The first step is to install the packages that are required to run
eclipse and eclim:

-   Install a java jdk, xvfb, and the necessary build tools to compile
    eclim's nailgun client during installation (make, gcc, etc).

        $ sudo apt-get install openjdk-6-jdk xvfb build-essential

Then you'll need to install eclipse. You may do so by installing it from
your distro's package manager or using a version found on
[eclipse.org](http://eclipse.org/downloads/). If you choose to install a
version from you package manager, make sure that the version to be
installed is compatible with eclim since the package manager version can
often be out of date. If you choose to install an
[eclipse.org](http://eclipse.org/downloads/) version, you can do so by
first downloading eclipse using either a console based browser like
elinks, or you can navigate to the download page on your desktop and
copy the download url and use wget to download the eclipse archive. Once
downloaded, you can then extract the archive in the directory of your
choice.

    $ wget <eclipse_mirror>/eclipse-<version>-linux-gtk.tar.gz
    $ tar -zxf eclipse-<version>-linux-gtk.tar.gz

> **note**
>
> Depending on what distribution of eclipse you installed and what eclim
> features you would like to be installed, you may need to install
> additional eclipse features. If you installed eclipse from your
> package manager then your package manager may also have the required
> dependency (eclipse-cdt for C/C++ support for example). If not, you
> can install the required dependency using eclipse's p2 command line
> client. Make sure the command references the correct repository for
> your eclipse install (juno in this example) and that you have Xvfb
> running as described in the last step of this guide:
>
>     DISPLAY=:1 ./eclipse/eclipse -nosplash -consolelog -debug
>       -application org.eclipse.equinox.p2.director
>       -repository http://download.eclipse.org/releases/juno
>       -installIU org.eclipse.wst.web_ui.feature.feature.group
>
> For a list of eclim plugins and which eclipse features they require,
> please see the [installer
> dependencies](https://github.com/ervandew/eclim/blob/master/org.eclim.installer/build/resources/dependencies.xml).
> Note that the suffix '.feature.group' must be added to the dependency
> id found in that file when supplying it to the '-installIU' arg of the
> above command.

Once eclipse is installed, you can then install eclim utilizing the
eclim installer's automated install option (see the installer-automated
section for additional details):

``` {.sourceCode .bash}
$ java \
  -Dvim.files=$HOME/.vim \
  -Declipse.home=/opt/eclipse \
  -jar eclim_eclim_release.jar install
```

The last step is to start Xvfb followed by eclimd:

    $ Xvfb :1 -screen 0 1024x768x24 &
    $ DISPLAY=:1 ./eclipse/eclimd -b

When starting Xvfb you may receive some errors regarding font paths and
possibly dbus and hal, but as long as Xvfb continues to run, you should
be able to ignore these errors.

The first time you start eclimd you may want to omit the 'start'
argument so that you can see the output on the console to ensure that
eclimd starts correctly.

### Upgrading

The upgrading procedure is the same as the installation procedure but
please be aware that the installer will remove the previous version of
eclim prior to installing the new one. The installer will delete all the
org.eclim\* eclipse plugins along with all the files eclim adds to your
.vim or vimfiles directory (plugin/eclim.vim, eclim/\*\*/\*).

Uninstall
---------

To uninstall eclim you can use any eclim distribution jar whose version
is 1.7.5 or greater by running it with the 'uninstaller' argument like
so:

``` {.sourceCode .bash}
$ java -jar eclim_eclim_release.jar uninstaller
```

That will open a graphical wizard much like the install wizard which
will ask you again for the location of your vimfiles and eclipse home
where you've installed eclim and will then remove the eclim installation
accordingly.

> **note**
>
> The uninstaller is backwards compatible and can be used to uninstall
> older versions of eclim.

### Unattended (automated) uninstall

Like the installer, the uninstaller also supports an unattended
uninstall. You just need to supply your vim files and eclipse paths as
system properties:

``` {.sourceCode .bash}
$ java \
  -Dvim.files=$HOME/.vim \
  -Declipse.home=/opt/eclipse \
  -jar eclim_eclim_release.jar uninstall
```

**Required Properties:**

-   **eclipse.home** - The absolute path to your eclipse installation.
-   **vim.files** (or **vim.skip=true**) - The absolute path to your vim
    files directory. Or if you never installed the vim files
    (emacs-eclim users for example) you can supply `-Dvim.skip=true`
    instead.

[1]: data:image/png;base64,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

[2]: data:image/png;base64,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
