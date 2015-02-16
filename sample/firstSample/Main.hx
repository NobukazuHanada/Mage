package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.CreateAccountFormView;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.root);

			var sampleView = new SampleView({message:"hello!", name:"@nobkz"});
			base.root.appendChild(sampleView.root);

			var accountView = new CreateAccountFormView();
			base.root.appendChild(accountView.root);
		});
	}
}