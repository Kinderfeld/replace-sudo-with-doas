# replace-sudo-with-doas

## Overview

This script replaces the bloated `sudo` package with the simpler,
more lightweight `doas`. It automates the process of removing `sudo`,
installing `doas`, configuring it for persistent use, and symlinking
doas to `/usr/bin/sudo` for compatibility.

Currently supports **Debian**, **Arch**, **Alpine**, and **FreeBSD**.

## Why

`sudo` has grown over time into a large and complex utility.
For users who prefer simplicity, minimalism, and better auditability,
`doas` (originally from **OpenBSD**) is a lean and secure alternative.
It does just one thing — lets authorized users run commands as root
— and it does it very well.

## Installation

You can install and run the script (as root) directly from GitHub:

```sh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/Kinderfeld/replace-sudo-with-doas/main/replace_sudo_with_doas.sh)"
```

Follow the prompt to specify your operating system,
and the script takes care of the rest.

## Legal

This project is released into the public domain under **The Unlicense**.

More information in:

- _LICENSE_;

- [_Unlicense Website_](https://unlicense.org/).

