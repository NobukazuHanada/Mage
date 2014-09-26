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