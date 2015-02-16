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

@:build(mage.CompileCSS.generate(
'package sample.view;

div > label { color : red; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view;

<div>
	<label for="email">email</label>
	<input(email) id="email" type="text"><br>
	<label for="user_id">userid</label>
	<input(userId) id="user_id" type="text"><br>
	<label for="pass">passowrd</label>
	<input(loginForm) id="pass" type="text"><br>
	<label for="confirm">confirm</label>
	<input id="confirm" type="text" mage-var="confirm"><br>
	<input(submit) type="submit">
</div>'
))
class CreateAccountFormView{}


@:build(mage.CompileCSS.generate(
'package sample.view2;

p { color : blue; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view2;

<div>
	<p>{message}</p>
	<p>{name}</p>
</div>'
))
class SampleView{}

@:build(mage.CompileHTML.generate(
'package sample.base;

<div></div>	'
))
class BaseView{}

```

**sample/Main.hx**

```haxe
package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.CreateAccountFormView;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.root);

			var sampleView = new SampleView({message:"hello!", name:"@nobkz"});
			base.root.appendChild(sampleView.root);

			var accountView = new CreateAccountFormView();
			base.root.appendChild(accountView.root);
		});
	}
}
```

**build.hxml**

```
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
	<title> first Sample Mage </title>
	<link href="mage.css" rel="stylesheet" type="text/css">
</head>
<body>
	<script src="main.js"></script>
</body>
</html>
```
