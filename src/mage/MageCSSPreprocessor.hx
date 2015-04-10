package mage;

import simple.monads.Result;
import simple.monads.Parser;

using Lambda;
using mage.MageCSS;

class MageCSSPreprocessor{
    public static function preprocess(inputText:String) : String {
        var result = MageCSSParser.parser(inputText);
        return switch (result) {
            case Success(ParseItem(p,_)): evalMageCSS(p);
            case Error(e): throw "css parse error : " + e.msg; 
        }
    }

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
    };
                                                          
    private static function cssSelectorAddPackage(cssPackage,selector)
        return switch(selector){
        case SElement(element): element.toString() + "." + cssPackage;
        case SDescendant(parent,descendant):
            cssSelectorAddPackage(cssPackage,parent) + " " + cssSelectorAddPackage(cssPackage,descendant);
        case SChild(parent,descendant):
            cssSelectorAddPackage(cssPackage,parent) + " > " + cssSelectorAddPackage(cssPackage,descendant);
        case SPlus(parent,descendant):
            cssSelectorAddPackage(cssPackage,parent) + " + " + cssSelectorAddPackage(cssPackage,descendant);
        case STilda(parent,descendant):
            cssSelectorAddPackage(cssPackage,parent) + " ~ " + cssSelectorAddPackage(cssPackage,descendant);
        case SMany(parent,descendant):
            cssSelectorAddPackage(cssPackage,parent) + " , " + cssSelectorAddPackage(cssPackage,descendant);
    };
    
}
