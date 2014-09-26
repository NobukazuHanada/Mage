package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.SampleView2;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.nodes[0]);

			var sampleView = new SampleView("first!");
			base.component.appendChild(sampleView.nodes[0]);

			sampleView.input.addEventListener("change",function(e){
				sampleView.message.nodeValue = sampleView.input.value;
			});

			var sampleView2 = new SampleView2("second!");
			base.component.appendChild(sampleView2.nodes[0]);

			sampleView2.input.addEventListener("change",function(e){
				sampleView2.message.nodeValue = sampleView2.input.value;
			});

		});
	}
}