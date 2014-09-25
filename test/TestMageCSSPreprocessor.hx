package ;

import mage.MageCSS;
import mage.MageCSSPreprocessor;
import mage.MageCSSParser;
import simple.monads.Result;
import simple.monads.Parser;

import buddy.*;
using buddy.Should;
using Std;



class TestMageCSSPreprocessor extends BuddySuite implements Buddy {
  public function new() {
    describe("Mage CSSPreprocessor", {
      it("make new css code",{
          var cssCodeData = MageCSSParser.parser(
"package sample.package;

div {
  top : 10px;
}"
            );
        

          var result = switch (cssCodeData) {
            case Success(ParseItem(i,_)):
              MageCSSPreprocessor.evalMageCSS(i);
            case _: null;
          }

          result.should.be("div.sample-package{top:10px;}");
        });
    });
  }
}