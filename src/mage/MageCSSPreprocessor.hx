package mage;

using Lambda;
using mage.MageCSS;

class MageCSSPreprocessor{
	
	public static function evalMageCSS(mageCSS:MageCSS) : String {
		var cssPackage = mageCSS.cssPackage.split(".").join("-");

		return mageCSS.css.map(function(cssElement){
			var mageSelector = cssSelectorAddPackage(cssPackage,cssElement.selector);
			return mageSelector + "{" +
				cssElement.blocks
				.map(function(block)return block.property + ":" + block.value + ";" )
				.fold(function(blockText,acc)return acc + blockText,"")
			+"}";
		}).fold(function(selectorText,acc) return acc + selectorText, "");
	}

	private static function cssSelectorAddPackage(cssPackage,selector)
		return switch(selector){
				case SElement(element): element.toString() + "." + cssPackage;
				case SDescendant(parent,descendant):
					cssSelectorAddPackage(cssPackage,parent) + " " + cssSelectorAddPackage(cssPackage,descendant);
				case SChild(parent,descendant):
					cssSelectorAddPackage(cssPackage,parent) + " > " + cssSelectorAddPackage(cssPackage,descendant);
			};
	
}