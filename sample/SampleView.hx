package ;

import mage.CompileHTML;

@:build(mage.CompileHTML.generate(
'<div>
	<p>{{message}}</p>
	<input type="text" mage-var="input">
</div>'
))
class SampleView{}