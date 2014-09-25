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
	SChild(parent:SelectorElement,child:Selector);
	SDecendant(parent:SelectorElement,desendant:Selector);
}

enum SelectorElement{
	SID(name:String);
	SClass(name:String);
	STag(name:String);
}

typedef Block = {
	property : String,
	value : String
}