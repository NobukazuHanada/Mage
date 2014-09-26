package ;

import js.html.InputElement;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var sampleView = new SampleView("first!");
			js.Browser.document.body.appendChild(sampleView.nodes[0]);

			sampleView.input.addEventListener("change",function(e){
				sampleView.message.nodeValue = sampleView.input.value;
			});

			var sampleView2 = new SampleView.SampleView2("second!");
			js.Browser.document.body.appendChild(sampleView2.nodes[0]);

			sampleView2.input.addEventListener("change",function(e){
				sampleView2.message.nodeValue = sampleView2.input.value;
			});

		});
	}
}