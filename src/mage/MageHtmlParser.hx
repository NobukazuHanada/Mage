package mage;

import haxe.macro.Expr;

import simple.Monad;
import simple.monads.Parser;
import mage.MageCSSParser.Input;
import mage.MageCSSParser.ParserC;
import mage.MageCSSParser.ParseError;
using StringTools;
using Lambda;
using Std;

enum Node{
    E(name:String,attr:Array<{key:String,value:String}>,childNode:Array<Node>);
    Text(text:String);
    MageText(varname:String);
    MageE(name:String,attr:Array<{key:String,value:String}>,childNode:Array<Node>,varname:String);
}



class MageHtmlParser {
    macro public static function or(e:Array<Expr>) : Expr{
        e.reverse();
        var first = e.shift();
        var rest = e;
        return rest.fold(function(expr,acc) 
            return macro Parser.or(${expr},${acc}),first);
    }

    macro public static function and(e:Array<Expr>) : Expr{
        e.reverse();
        var first = e.shift();
        var rest = e;
        return rest.fold(function(expr,acc) 
            return macro Parser.and(${expr},${acc}),first);
    } 

    macro public static function many(e){
        return macro Parser.many($e);
    }

    macro public static function many1(e){
        return macro Parser.many1($e);
    }

	// to library?, begin
    public static function err<T>(msg, input) : ParseResult<Input,ParseError,T> return Error({ msg : msg, pos : input.pos, line : input.line});

    public static function failure<T>(msg : String) : ParserC<T>
        return function(input) return err(msg, input);

    public static function item(input:Input)
        return switch (input.item()) {
            case None: err("expected of item",input);
            case Some({ item : item, next : next }) : Success(ParseItem(item,next));
        }

    public static function eof(input:Input)
        return switch (input.item()) {
            case None: Success(ParseItem("",input));
            case _ : err("expected of eof",input);
        }

    public static function sat(check: String -> Bool)
        return Monad.do_m(Parser,{
                i < item;
                if( check(i) ) mPack(i) else failure("error");
            });

    public static var space = sat(function(s)return s.isSpace(0) );
     public static var nonspace = sat(function(s)return !s.isSpace(0));
    public static var spaces  = many(space);
    public static var spaces1 = many1(space);

    public static function char(c:String)
        return sat(function(i) return i == c );

    public static function nonchar(c:String)
        return sat(function(i) return i != c);

    public static function string(s:String)
        return if( s.length == 0 ) Parser.mPack("")
        else or(
            Monad.do_m(Parser,{
                x < char(s.charAt(0));
                xs < string(s.substring(1));
                mPack(x + xs);
            }),
            failure("expected " + s));

    public static function isAlphabet(c:String)
        return "ABCDEFGHIJKLNMOPQRSTUVWXYZabcdefghijklnmopqrstuvwxyz".split("").map(function(x) return x == c ).fold(function(x,acc) return acc || x, false);

    public static function isNumber(c:String)
        return "0123456789".split("").map(function(x) return x == c ).fold(function(x,acc) return acc || x, false);

    public static var alphabet = sat(isAlphabet);
    public static var number = sat(isNumber);

    public static var noEndTagNames = ["br","wbr","hr","img","col","base", "link","meta",
    "input","keygen","area","param","embed","source","track","command"];

    public static var noEndTagNameStrings = 
        noEndTagNames
        .map(function(name) return string(name))
        .fold(function(item,acc)
            return Parser.or(item,acc),failure("no noEndTag!"));
    

    public static var noEndTag = Monad.do_m(Parser,{
    	char("<");
    	name < noEndTagNameStrings;
    	attrs < tagAttrs;
        spaces;
        many(char("/"));
    	char(">");
    	mPack(E(name,attrs,[]));
    });

    public static var noEndMageTag = Monad.do_m(Parser,{
    	char("<");
    	name < noEndTagNameStrings;
    	char("(");
    	spaces;
    	varname < many(and(nonchar(")"),nonspace));
    	spaces;
    	char(")");
    	attrs < tagAttrs;
        spaces;
        many(char("/"));
    	char(">");
    	mPack(MageE(name,attrs,[],varname.join("")));
    });

    public static var mageTagBegin = Monad.do_m(Parser,{
    		char("<");
    		name < many(and(nonchar("/"),nonchar(">"),nonspace,nonchar("("),nonchar(")")));
    		char("(");
    		spaces;
    		varname < many(and(nonchar(")"),nonspace));
    		spaces;
    		char(")");
    		attrs < tagAttrs;
            spaces;
    		char(">");
    		mPack(MageE(name.join(""),attrs,[],varname.join("")));
    	});

    public static var tagBegin = Monad.do_m(Parser,{
    		char("<");
    		name < many(and(nonchar("/"),nonchar(">"),nonspace,nonchar("("),nonchar(")")));
    		attrs < tagAttrs;
            spaces;
    		char(">");
    		mPack(E(name.join(""),attrs,[]));
    	});

    public static var tagAttrs : ParserC<Array<{key:String,value:String}>> =many(Monad.do_m(Parser,{
    	spaces1;
    	attribute;
    }));

    public static var attrKeyChar = and(nonchar("="),nonchar(">"),nonchar("'"),nonchar('"'),nonspace,nonchar("/"));
    public static var attrValueChar = and(nonchar("="),nonchar(">"),nonchar("'"),nonchar('"'),nonchar("/"));

    public static var attribute = or(Monad.do_m(Parser,{
    	key < many1(attrKeyChar);
    	char("=");
    	value < many1(and(attrValueChar,nonspace));
    	mPack({key:key.join(""), value:value.join("")});
    }),
    Monad.do_m(Parser,{
        key < many1(attrKeyChar);
        char("=");
        char("'");
        value < many(attrValueChar);
        char("'");
        mPack({key:key.join(""), value:value.join("")});
    }),
    Monad.do_m(Parser,{
        key < many1(attrKeyChar);
        mPack({key:key.join(""), value:""});
        char("=");
        char('"');
        value < many(attrValueChar);
        char('"');
        mPack({key:key.join(""), value:value.join("")});
    }),
    Monad.do_m(Parser,{
        key < many1(attrKeyChar);
        mPack({key:key.join(""), value:""});
    }));

    public static function tagEnd(nameNode:Node){
    	return switch(nameNode){
    		case E(name,attr,_):
		    	Monad.do_m(Parser,{
		    		string("</"+name+">");
		    	});
		   	case MageE(name,attr,_,varname):
		   		Monad.do_m(Parser,{
		    		string("</"+name+">");
		    	});
		    case _: failure("error name");
    	}
    }

    public static function tag(input:Input)
    	return or(Monad.do_m(Parser,{
    		node < tagBegin;
    		childNodes < nodes;
    		tagEnd(node);
    		mPack(addChildNodes(node,childNodes));
    	}),Monad.do_m(Parser,{
    		node < tagBegin;
    		childNodes < many(or(text,mageText));
    		many(nonchar("<"));
    		mPack(addChildNodes(node,childNodes));
    	}))
    	(input);

   	 public static function mageTag(input:Input)
    	return or(Monad.do_m(Parser,{
    		node < mageTagBegin;
    		childNodes < nodes;
    		tagEnd(node);
    		mPack(addChildNodes(node,childNodes));
    	}),Monad.do_m(Parser,{
    		node < tagBegin;
    		childNodes < many(or(text,mageText));
    		many(nonchar("<"));
    		mPack(addChildNodes(node,childNodes));
    	}))
    	(input);

    public static function addChildNodes(node,childNodes)
    	return switch(node){
    		case E(name,attr,_): E(name,attr,childNodes);
    		case MageE(name,attr,_,varname): MageE(name,attr,childNodes,varname);
		    case _: null;
    	}
    

    public static function node(input:Input)
    	return or(text,mageText,noEndTag,noEndMageTag,tag,mageTag)(input);

    public static function nodes(input:Input)
    	return many(node)(input);


    public static var text = Monad.do_m(Parser,{
    	t < many1(and(nonchar("<"),nonchar(">"),nonchar("{"),nonchar("}")));
    	mPack(Text(t.join("")));
    });

    public static var mageText = Monad.do_m(Parser,{
    	char("{");
    	t < many1(and(nonchar("{"),nonchar("}")));
    	char("}");
    	mPack(MageText(t.join("")));
    });


    public static function parse(html:String) {
        return nodes(new Input(html));
    }
}


















