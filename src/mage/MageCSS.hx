package mage;

typedef MageCSS = { 
	cssPackage : String,
	css : Array<MageCSSElement>
};

typedef MageCSSElement = 
{
	selector : Selector,
	blocks : Array<Block>
}

enum Selector{
	SElement(e:SelectorElement);
	SChild(parent:Selector,child:Selector);
	SDescendant(parent:Selector,desendant:Selector);
	SPlus(parent:Selector, desendant:Selector);
	STilda(parent:Selector,desedant:Selector);
	SMany(head:Selector,rest:Selector);
}

enum SelectorElement{
	SID(name:String);
	SClass(name:String);
	SConnect(element:SelectorElement,classes:Array<String>);
	STag(name:String);
	SAttr(code:String);
}

typedef Block = {
	property : String,
	value : String
}

class SelectorElementTools {
	public static function toString(s:SelectorElement)
		return switch (s) {
			case SID(name): "#" + name;
			case SClass(name): "." + name;
			case SAttr(code): code;
			case STag(name): name;
			case SConnect(element,classes): toString(element) + "." + classes.join("."); 
		}
}