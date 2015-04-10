package ;

import js.html.InputElement;
import SampleView.BaseView;
import SampleView.CreateAccountFormView;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var base = new BaseView();
			js.Browser.document.body.appendChild(base.root);

			var sampleView = new SampleView();
			sampleView.update({message:"Hello", name:"@nobkz"});
			base.root.appendChild(sampleView.root);

			var accountView = new CreateAccountFormView();
			accountView.submit.addEventListener("click",function(e){
				trace("hello");
			});
			base.root.appendChild(accountView.root);
		});
	}
}