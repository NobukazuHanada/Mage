package mage;

import mage.MageCSS;

using Lambda;

class MageCSSPreprocessor{
	
	public static function evalMageCSS(mageCSS:MageCSS) : String {
		var cssPackage = mageCSS.cssPackage.split(".").join("-");

		return mageCSS.css.map(function(cssElement){
			var mageSelector = switch(cssElement.selector){
				case SElement(SClass(name)): name + "." + cssPackage;
				case SElement(SID(name)): name + "." + cssPackage;
				case SElement(STag(name)): name + "." + cssPackage;
				case _:
					"";
			}
			return mageSelector + "{" +
				cssElement.blocks
				.map(function(block)return block.property + ":" + block.value + ";" )
				.fold(function(blockText,acc)return acc + blockText,"")
			+"}";
		}).fold(function(selectorText,acc) return acc + selectorText, "");
	}
}