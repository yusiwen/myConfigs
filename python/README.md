# Python

Configurations for Python environment.

## Pip

Ubuntu's vanilla python-pip package is out-dated, so get pip from Python's official site:

```text
$ curl -O https://bootstrap.pypa.io/get-pip.py --proxy host:port
$ sudo python get-pip.py
# or install to $HOME/.local/bin
$ python get-pip.py --user

# install pre-requisite packages for building:
$ sudo apt-get install libexpat1-dev libpython-all-dev libpython-dev libpython2.7-dev python-all python-all-dev python-dev python-pkg-resources python2.7-dev
```

For more details, check out this [official page](https://pip.pypa.io/en/latest/installing.html#install-pip)

## Using Pip behind a proxy

```sh
pip --proxy host:port install XXX
```

## Virtualenv

Virtualenv allows you to create local, isolated Python environments, each with a different set of installed packages. As a bonus, virtualenv installs pip into each new environment that you create, so you don’t even need to install pip globally.

```sh
curl -O https://bitbucket.org/ianb/virtualenv/raw/tip/virtualenv.py
python virtualenv.py ~/venv/base
```

Or install `virtualenv` from pip:

```sh
pip install virtualenv
virtualenv ~/venv/base
```

Then, Make this environment your default Python environment by adding the following line to the bottom of your ~/.profile or ~/.bash_profile file:

```sh
source ~/venv/base/bin/activate
```

For more details, check out this [blog post](http://dubroy.com/blog/so-you-want-to-install-a-python-package/#the-better-way)
