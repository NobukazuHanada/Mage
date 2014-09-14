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