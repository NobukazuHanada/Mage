package ;

import mage.CompileHTML;

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