package ;

import mage.MageCSSParser;
import mage.MageCSSParser.Input;

import buddy.*;
using buddy.Should;
using Std;



class TestMageCSSParser extends BuddySuite implements Buddy {
  public function new() {
    describe("Mage CSS Parser", {
      it("success to parse css",{

        var result = MageCSSParser.cssElement(new Input(
"div {
  top : 10px;
  bottom : 10px;
} "
          ));

        switch (result) {
          case Success(ParseItem(p,_)):
            p.string().should.be(
              { selector : "div",  
                block : [{ property : "top" ,  value : "10px" },
                         { property : "bottom" ,  value : "10px" }] }.string() );
          case _:
            false.should.be(true);
        }
         
      	});
    });
  }
}