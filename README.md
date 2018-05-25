# D Bindings for webview

D programming language bindings for [webview](https://github.com/zserge/webview) a tiny cross platform webview library.  

Webview is cross platform, however and the bindings can support the other platforms. Current development environment is a Ubuntu 18.04 system. Macos is already started, windows I will have to gain access to a machine. 

## System Dependancies to build webview from source on linux

### Install webview's dependancies

 * build tools 
   * c compiler
   * cmake
   * gnu make
 * gtk+-3.0
 * webkit2gtk-4.0

on Ubuntu 18.04

```
$ sudo apt install build-essential cmake libgtk-3-0 libgtk-3-dev libwebkit2gtk-4.0-37 libwebkit2gtk-4.0-dev
```

### clone the webview dependancy project 

```
git clone https://github.com/zserge/webview.git
```


### Build and Install webview

from the cloned webview git project

```
$ mkdir build
$ cd build
$ cmake -DCMAKE_INSTALL_PREFIX="/usr/" ..
$ make
$ sudo make install
```

## dub.json dependancies for your project 

```
"webview-d": "~>0.0.2"
```

dub library dependancy for linking

```
"libs": ["webview"]
```

## example

see included example ``example/webview-d_test`` project

```
import std.stdio;

import webview;

int main()
{
	
	webview_simple("test","https://www.dlang.org",1024,768,1);

	return 0;
}
```
