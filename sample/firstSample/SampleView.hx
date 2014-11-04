package ;

@:build(mage.CompileCSS.generate(
'package sample.view;

div > label { color : red; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view;

<div>
	<label for="email">email</label>
	<input id="email" type="text" mage-var="email"><br>
	<label for="user_id">userid</label>
	<input id="user_id" type="text" mage-var="userId"><br>
	<label for="pass">passowrd</label>
	<input id="pass" type="text" mage-var="loginFrom"><br>
	<label for="confirm">confirm</label>
	<input id="confirm" type="text" mage-var="confirm"><br>
	<input mage-var="submit" type="submit">
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
	<p>{{message}}</p>
	<p>{{name}}</p>
</div>'
))
class SampleView{}

@:build(mage.CompileHTML.generate(
'package sample.base;

<html lang="ja">
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" type="text/css" href="mage.css">
	<title>Mage Sample</title>
</head>
<body>
	<div mage-var="component"></div>	
</body>
</html>'
))
class BaseView{}