package ;

import mage.MageHtmlParser;
import mage.MageCSSParser.Input;
import simple.monads.Result;
import simple.monads.Parser.ParseItem;

import buddy.*;
using buddy.Should;
using Std;

class TestMageHtmlParser extends BuddySuite implements Buddy{
    public function new(){
    	describe("MageHtmlParser",{
    		function success(nodeName)
    			return Success(ParseItem(E(nodeName,[], []),new Input("",0,11)));

    		it("simple dom parse", {
    			var result = MageHtmlParser.parse("<div></div>");
    			switch(result){
    				case Success(ParseItem(e,_)): e.string().should.be([E("div",[],[])].string());
    				case _: fail("Parser Error");
    			}
    		});
    		it("simple dom and text node parsed",{
    			var result = MageHtmlParser.parse("<div>text</div>");
    			 switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be([E("div",[],[Text("text")])].string());
    				case _: fail("Parser Error");
    			}
    		});
    		it("simple dom and nexted dom parse",{
    			var result = MageHtmlParser.parse("<div><div></div></div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be([E("div",[],
    						[E("div",[],[])])].string());
    				case _: fail("Parser Error");
    			}
    		});
    		it("simple dom and nexted dom and textNodeparse",{
    			var result = MageHtmlParser.parse("<div>divtext<p>sample</p>divtext</div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be([
    						E("div",[],
    							[Text("divtext"),
	    						E("p",[],[Text("sample")]),
    							Text("divtext")]
    						)].string());
    				case _: fail("Parser Error");
    			}
    		});

    		 it("simple dom has attrs",{
    			var result = MageHtmlParser.parse("<div sample=foo bar=baz></div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[{key:"sample",value:"foo"},
    							{key:"bar",value:"baz"}],[])].string());
    				case _: fail("Parser Error");
    			}
    		});


    		 it("simple dom has attrs",{
    			var result = MageHtmlParser.parse("<div sample=foo bar=baz></div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[{key:"sample",value:"foo"},{key:"bar",value:"baz"}],[])].string());
    				case _: fail("Parser Error");
    			}
    		});

    		it("simple dom has attrs single quatation",{
    			var result = MageHtmlParser.parse("<div sample='foo' bar='baz'></div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[{key:"sample",value:"foo"},{key:"bar",value:"baz"}],[])].string());
    				case _: fail("Parser Error");
    			}
    		});

    		 it("simple dom has attrs dobule quatation",{
    			var result = MageHtmlParser.parse('<div sample="foo" bar="baz"></div>');
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[{key:"sample",value:"foo"},{key:"bar",value:"baz"}],[])].string());
    				case _: fail("Parser Error");
    			}
    		});

    		it("simple no end tag",{
    			var result = MageHtmlParser.parse("<br>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("br",[],[])].string());
    				case _: fail("Parser Error");
    			}
    		});

    		it("nested no end tag",{
    			var result = MageHtmlParser.parse("<div>line1<br>line2</div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[],
    							[
    								Text("line1"),
    								E("br",[],[]),
    								Text("line2")
    							])].string());
    				case _: fail("Parser Error");
    			}
    		});
    		it("nested emit end tag",{
    			var result = MageHtmlParser.parse("<div><p>line1<p>line2</div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[],
    							[ E("p",[],[Text("line1")]),
    							  E("p",[],[Text("line2")])
    							])].string());
    				case _: fail("Parser Error");
    			}
    		});

    		it("simple mage text node",{
    			var result = MageHtmlParser.parse("<div>{t}</div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[],
    							[MageText("t")]
    							)].string());
    				case _: fail("Parser Error");
    			}
    		});

    		it("simple mage text node",{
    			var result = MageHtmlParser.parse("<div>{t}{t2}{t3}</div>");
    			   switch(result){
    				case Success(ParseItem(e,_)): 
    					e.string().should.be(
    						[E("div",[],
    							[MageText("t"),MageText("t2"),MageText("t3")]
    							)].string());
    				case _: fail("Parser Error");
    			}
    		});




            it("no end tag attrs",{
                var result = MageHtmlParser.parse('<input type="text" />');
                   switch(result){
                    case Success(ParseItem(e,_)): 
                        e.string().should.be(
                            [E("input",[{key:"type",value:"text"}],[])].string());
                    case _: fail("Parser Error");
                }
            });


            it("element attribute non value pattern",{
                var text = '<textarea name="" id cols="30" rows="10" ></textarea>';
                var result = MageHtmlParser.parse(text);
                switch(result){
                    case Success(ParseItem(e,_)): 
                        e.string().should.be(
                            [E("textarea",[
                                {key:"name",value:""},
                                {key:"id",value:""},
                                {key:"cols",value:"30"},
                                {key:"rows",value:"10"}],[])].string());
                    case _: fail("Parser Error");
                }
            });


            it("mage href attrbuite",{
                var result = MageHtmlParser.parse('<a href="/">');
                switch(result){
                    case Success(ParseItem(e,_)): 
                        e.string().should.be(
                            [E("a",[{key:"href",value:"/"}],[])].string());
                    case _: fail("Parser Error");
                }
            });

            it("svg tags",{
                var text =
                '<svg><rect /><path /></svg>';
                var result = MageHtmlParser.parse(text);
                switch(result){
                    case Success(ParseItem(e,_)): 
                        e.string().should.be(
                            [E("svg",[],[E("rect",[],[]),E("path",[],[])])].string());
                    case _: fail("Parser Error");
                }
            });

            it("comment out test",{
                var text =
                '<div><!-- <div>fdafda</div> --></div>';
                var result = MageHtmlParser.parse(text);
                switch(result){
                    case Success(ParseItem(e,_)): 
                        e.string().should.be(
                            [E("div",[],[CommentOut])].string());
                    case _: fail("Parser Error");
                }
            });

    	});
    }
}