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
	<p>{warning}</p>
	<label for="user_id">userid</label>
	<input id="user_id" type="text"><br>
	<label for="pass">passowrd</label>
	<input id="pass" type="text"><br>
	<label for="confirm">confirm</label>
	<input id="confirm" type="text" ><br>
	<input( id="submit" type="submit">
</div>'
))
class AccountFormView{}


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

<div>
	<SampleView id="sampleView" />
	<AccountFormView id="sampleView" />
</div>'
))
class NestedView{
	public var childView : AccountFormView;

	public function new(data){

		this.accountForm.appendChild(this.childView.root);
	}
}