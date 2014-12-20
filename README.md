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
'package sample.base;


<div mage-var="component"></div>'
))
class BaseView{}

@:build(mage.CompileCSS.generate(
'package sample.view;

p { color : red; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view;

<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView{}


@:build(mage.CompileCSS.generate(
'package sample.view2;

p { color : blue; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view2;

<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView2{}

```

**sample/Main.hx**

```haxe
package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.SampleView;
import SampleView.SampleView2;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.nodes[0]);

			var sampleView = new SampleView({ message : "first!" });
			base.component.appendChild(sampleView.nodes[0]);

			sampleView.input.addEventListener("change",function(e){
				sampleView.message.nodeValue = sampleView.input.value;
			});

			var sampleView2 = new SampleView2({ message : "second!" });
			base.component.appendChild(sampleView2.nodes[0]);

			sampleView2.input.addEventListener("change",function(e){
				sampleView2.message.nodeValue = sampleView2.input.value;
			});

		});
	}
}
```

**build.hxml**

```
-cp sample
-lib Mage
-js main.js
-main Main
```

**index.html**


```html
<!DOCTYPE html>
<script src="main.js"></script>
```
