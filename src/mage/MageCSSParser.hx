package mage;


import mage.MageCSS;
import simple.Monad;
import simple.monads.Option;
using simple.monads.Parser;
using StringTools;
using Lambda;
using Std;

class Input{
    public var inputData(default, null) : String;
    public var pos(default, null): Int;
    public var line(default, null): Int;

    public function new(s:String, line:Int=0, pos:Int=0){
        this.inputData = s;
        this.pos = pos;
        this.line = line;
    }

    public function item()
        return if( this.inputData.length == 0 ) None
        else if(this.inputData.charAt(0) != "\n")
            Some({ item : this.inputData.charAt(0),  
                   next : new Input(this.inputData.substring(1), this.line, this.pos+1)});
        else Some({ item : this.inputData.charAt(0), 
                    next : new Input(this.inputData.substring(1),  this.line+1)});
}


typedef ParseError = { line : Int, pos : Int, msg : String };
typedef ParserC<T> = ParserDef<Input,ParseError,T>

class MageCSSParser{
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
    public static var spaces = space.many();
    public static var spaces1 = space.many1();

    public static function char(c:String)
        return sat(function(i) return i == c );

    public static function nonchar(c:String)
        return sat(function(i) return i != c);

    public static function string(s:String)
        return if( s.length == 0 ) Parser.mPack("")
        else Monad.do_m(Parser,{
                x < char(s.charAt(0));
                xs < string(s.substring(1));
                mPack(x + xs);
            }).or(failure("expected " + s));

    public static function isAlphabet(c:String)
        return "ABCDEFGHIJKLNMOPQRSTUVWXYZabcdefghijklnmopqrstuvwxyz".split("").map(function(x) return x == c ).fold(function(x,acc) return acc || x, false);

    public static function isNumber(c:String)
        return "0123456789".split("").map(function(x) return x == c ).fold(function(x,acc) return acc || x, false);

    public static var alphabet = sat(isAlphabet);
    public static var number = sat(isNumber);

    // end

    public static var name = Monad.do_m(Parser,{
        s < alphabet;
        ss < (alphabet.or(number).or(char("_")).or(char("-"))).many();
        mPack([s].concat(ss).join(""));
        });

    public static var sid = Monad.do_m(Parser,{
        char("#");
        n < name;
        mPack(SID(n));
        });

    public static var sclass = Monad.do_m(Parser,{
        char(".");
        n < name;
        mPack(SClass(n));
        });

    public static var stag = Monad.do_m(Parser,{
        n < name;
        mPack(STag(n));
        });

    public static var sattr = Monad.do_m(Parser,{
        char("[");
        n < nonchar("]").many();
        char("]");
        mPack(SAttr("[" + n.join("") + "]"));
        });

    public static var sconnect = Monad.do_m(Parser,{
        n < sid.or(sclass).or(stag).or(sattr);
        names < (Monad.do_m(Parser,{
            char(".");
            name;
            })).many1();
        mPack(SConnect(n,names));
        });

    public static var selement = sconnect.or(sid).or(sclass).or(stag).or(sattr);


    public static function selector(input:Input) : ParseResult<Input,ParseError,Selector> 
        return Monad.do_m(Parser,{
            selem < selement;
            spaces1;
            srest < selector;
            mPack(SDescendant(SElement(selem),srest));
            })
            .or(Monad.do_m(Parser,{
                selem < selement;
                spaces;
                char(">");
                spaces;
                srest < selector;
                mPack(SChild(SElement(selem),srest));
            }))
            .or(Monad.do_m(Parser,{
                elem < selement;
                mPack(SElement(elem));
            }))(input);

    public static var property =   Monad.do_m(Parser,{
    	s < nonchar(":").and(nonchar(" ")).many1();
    	mPack(s.join(""));
    	});

    public static var value =  Monad.do_m(Parser,{
    	s < nonchar(";").and(nonchar(" ")).many1();
    	mPack(s.join(""));
    	});

    public static var block = Monad.do_m(Parser,{
    	spaces;
    	p < property;
    	spaces;
    	char(":");
    	spaces;
    	v < value;
    	spaces;
    	char(";");
    	mPack({property:p, value:v});
    	})
    	.or(failure("block error"));

    public static var blocks = block.many();


    public static var cssElement : ParserC<MageCSSElement> = Monad.do_m(Parser,{
    	s < selector;
    	spaces;
    	char("{");
    	spaces;
    	bs < blocks;
    	spaces;
    	char("}");
    	spaces;
    	mPack({selector:s,blocks:bs});
    	});

    public static var csspackage = Monad.do_m(Parser,{
        spaces;
        string("package");
        spaces1;
        p < (alphabet.or(number).or(char(".")).or(char("-")).or(char("_"))).many();
        char(";");
        mPack(p.join(""));
        });

    public static var css = Monad.do_m(Parser,{
        csspack < csspackage;
        spaces;
    	css < cssElement.many();
        spaces;
    	eof;
    	mPack({cssPackage:csspack,css:css});
    	});

    public static function parser(csstext:String)  return css(new Input(csstext));

}