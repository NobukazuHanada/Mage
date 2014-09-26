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

p {
  color : red;
}

div {
  background-color : blue;
}"
            );
        

          var result = switch (cssCodeData) {
            case Success(ParseItem(i,_)):
              MageCSSPreprocessor.evalMageCSS(i);
            case _: null;
          }

          result.should.be("p.sample-package{color:red;}div.sample-package{background-color:blue;}");
        });
    });
  }
}