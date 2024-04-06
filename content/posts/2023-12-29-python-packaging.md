---
layout: post
draft: false
title: "Python Packaging (2024)"
slug: "pythonpack"
date: "2023-12-29 17:29:33+11:00"
lastmod: "2023-12-29 17:29:33+11:00"
comments: false
categories:
  - python
tags:
  - python
  - dev
  - code
---

- [sysconfig](#sysconfig)
- [Project Structure](#project-structure)
- [Setup Script](#setup-script)
- [Distribution Archives](#distribution-archives)
- [Distribution](#distribution)

## sysconfig

The process of bundling Python code into a format that eases distribution and sharing. First up, I find it helps to get a concrete understanding of how the specific python distro I'm working with is configured, of paricular interest are the various system paths that will be visited for package dependencies. The built-in [sysconfig](https://docs.python.org/3/library/sysconfig.html) module neatly manages and surfaces this information.

```
python -m sysconfig
```

On a Windows system:

```bat
PS C:\Users\ben\git\brightsnakes> python -m sysconfig
Platform: "win-amd64"
Python version: "3.11"
Current installation scheme: "nt"

Paths:
        data = "C:\Python311"
        include = "C:\Python311\Include"
        platinclude = "C:\Python311\Include"
        platlib = "C:\Python311\Lib\site-packages"
        platstdlib = "C:\Python311\Lib"
        purelib = "C:\Python311\Lib\site-packages"
        scripts = "C:\Python311\Scripts"
        stdlib = "C:\Python311\Lib"
...
```

On a Linux system:

```bash
$ python3 -m sysconfig
Platform: "linux-x86_64"
Python version: "3.10"
Current installation scheme: "posix_local"

Paths:
        data = "/usr/local"
        include = "/usr/include/python3.10"
        platinclude = "/usr/include/python3.10"
        platlib = "/usr/local/lib/python3.10/dist-packages"
        platstdlib = "/usr/lib/python3.10"
        purelib = "/usr/local/lib/python3.10/dist-packages"
        scripts = "/usr/local/bin"
        stdlib = "/usr/lib/python3.10"
...
```

On a Linux system under a virtualenv:

```bash
$ poetry run python3 -m sysconfig
Platform: "linux-x86_64"
Python version: "3.11"
Current installation scheme: "venv"

Paths:
        data = "/home/bms/.cache/pypoetry/virtualenvs/brightsnakes-u3bhK9-x-py3.11"
        include = "/usr/include/python3.11"
        platinclude = "/usr/include/python3.11"
        platlib = "/home/bms/.cache/pypoetry/virtualenvs/brightsnakes-u3bhK9-x-py3.11/lib/python3.11/site-packages"
        platstdlib = "/home/bms/.cache/pypoetry/virtualenvs/brightsnakes-u3bhK9-x-py3.11/lib/python3.11"
        purelib = "/home/bms/.cache/pypoetry/virtualenvs/brightsnakes-u3bhK9-x-py3.11/lib/python3.11/site-packages"
        scripts = "/home/bms/.cache/pypoetry/virtualenvs/brightsnakes-u3bhK9-x-py3.11/bin"
        stdlib = "/usr/lib/python3.11"
```

_TODO_: how to add custom package paths, using env vars, or sysconfig directly

## Version number

There's [several ways](https://packaging.python.org/en/latest/guides/single-sourcing-package-version/) to approach managing a single source of truth version number for a package, such as keeping a `VERSION` text file and having `setup.py` read it, or abandon keeping a version in your repo at all and instead infer this from Git using [setuptools_scm](https://pypi.org/project/setuptools-scm/), or in the case of poetry the `poetry-dynamic-versioning[plugin]` plugin.

## Project Structure

A typical Python package consists of a directory (aka package) containing an `__init__.py` other Python source files. The `__init__.py` file is executed when the package is imported, and it's often left empty but must exist in order for Python to recognise the directory as a standard package.

## Setup Script

The setup script (`setup.py` or `pyproject.toml` for recent versions) specifies metadata about the package like its name, version, author, and dependencies. It also instructs the packaging tools on how to build the package.

## Distribution Archives

Once the package and setup script are prepared, you can use tools like `setuptools` and `wheel` to create distribution archives (like `.tar.gz` or `.whl` files). These archives contain everything needed to install the package, including the package code and the setup script.

## Distribution

Finally, you can distribute the package by uploading the distribution archives to the Python Package Index (PyPI), a public repository of software for the Python programming language. Users can then install your package using pip, the standard package installer for Python.

## Poetry

```bash
poetry self add "poetry-dynamic-versioning[plugin]"
poetry source add --priority=supplemental private http://localhost:8080/simple/
poetry publish --repository private
```
