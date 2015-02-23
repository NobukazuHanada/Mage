package ;

import js.html.InputElement;

class Main{
	public static function main(){
		js.Browser.window.addEventListener("load",function(e){
			var view = new NestedView({message:"hello!",name:"nobkz"});
			js.Browser.document.body.appendChild(view.root);
		});
	}
}