Mage
====

Haxe MVW Frontend Framework

## Install

install this command

```
haxelib install Mage
```

add build.hxml

```
-lib Mage
```


## Example

**sample/SampleView.hx**

```haxe
package ;

import mage.CompileHTML;

@:build(mage.CompileHTML.generate(
'<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView{}

```

**sample/Main.hx**

```haxe
package ;

import js.html.InputElement;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var sampleView = new SampleView("first!");
			js.Browser.document.body.appendChild(sampleView.nodes[0]);

			sampleView.input.addEventListener("change",function(e){
				sampleView.message.nodeValue = ((cast sampleView.input) : InputElement).value;
			});

		});
	}
}
```

**build.hxml

```
-cp sample
-lib Mage
-js main.js
-main Main
```

**index.html**


```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>test</title>
  <script src="main.js"></script>
</head>
<body>

</body>
</html>
```
