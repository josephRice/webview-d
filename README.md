# D Bindings for webview

D programming language bindings for [webview](https://github.com/zserge/webview) a tiny cross platform webview library.  

## dub dependancies

```
"webview-d": "~>0.0.1"
```

dub library dependancy for linking

```
"libs": ["webview"]
```

## example

```
import std.stdio;

import webview;

int main()
{
	
	webview_simple("test","https://www.dlang.org",1024,768,1);

	return 0;
}
```