package postalk;

@:build(mage.CompileCSS.generate(
'package postalk.postit;

div {
	z-index: 3;
}
'
))
@:build(mage.CompileHTML.generate(
'package postalk.postit;

<div>
	{{text}}
</div>
'))
class Postit{}