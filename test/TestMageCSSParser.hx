package ;

import mage.MageCSS;
import mage.MageCSSParser;
import mage.MageCSSParser.Input;

import buddy.*;
using buddy.Should;
using Std;



class TestMageCSSParser extends BuddySuite implements Buddy {
  public function new() {
    describe("Mage CSS Parser", {
      it("success to parse css",{

        var result = MageCSSParser.parser(
"
package sample.package;

div {
  top : 10px;
}
");

        switch (result) {
          case Success(ParseItem(p,_)):
            p.cssPackage.should.be("sample.package");
            p.css[0].selector.string().should.be(SElement(STag("div")).string());
            p.css[0].blocks[0].string().should.be({ property : "top", value : "10px" }.string());
          case error:
            trace(error);
            false.should.be(true);
        }
         
      	});
    });
  }
}