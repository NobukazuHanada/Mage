package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.CreateAccountFormView;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.nodes[0]);

			var sampleView = new SampleView({message:"hello!", name:"@nobkz"});
			base.component.appendChild(sampleView.nodes[0]);

			var accountView = new CreateAccountFormView();
			base.component.appendChild(accountView.nodes[0]);
		});
	}
}