# ePick

A little color picker tool for use in elementaryOS.

Inspired by gpick I wanted to put my hands on an own little color picker which is super fast at hand since it can reside in the systray.

## Installation

Clone the repository, then

~~~
$ mkdir build
$ cd build
$ cmake -DCMAKE_INSTALL_PREFIX=/usr/ ../
$ make
# make install

~~~

## Setup

ePick is configured completely via `gsettings`, so use `dconf-editor` (gui) or `gsettings` (cli) to adjust the settings. The path is `org.pantheon.epick`




