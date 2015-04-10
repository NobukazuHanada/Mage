package ;

@:build(mage.CompileCSS.generate(
'package sample.view;

div > label { color : red; }'
))
@:build(mage.CompileHTML.generate(
'package sample.view;

<div>
	<label for="email">email</label>
	<input id="email" type="text"><br>
	<label for="user_id">userid</label>
	<input id="userId" id="user_id" type="text"><br>
	<label for="pass">passowrd</label>
	<input id="pass" type="text"><br>
	<label for="confirm">confirm</label>
	<input id="confirm" type="text" mage-var="confirm"><br>
	<input id="submit" type="submit">
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