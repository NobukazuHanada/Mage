package ;

import mage.MageCSS;
import mage.MageCSSParser;
import mage.MageCSSParser.Input;
import simple.monads.Result;
import simple.monads.Parser;

import buddy.*;
using buddy.Should;
using Std;
using TestUtil;



class TestMageCSSParser extends BuddySuite implements Buddy {
  public function new() {
    describe("Mage CSS Parser", {
      it("tag selector parse",{
        var result = MageCSSParser.parser("package ;div {}").mustSuccess();
        result.css[0].selector.string().should.be(SElement(STag("div")).string());
      });

      it("id selector parse",{
        var result = MageCSSParser.parser("package ;#foo {}").mustSuccess();
        result.css[0].selector.string().should.be(SElement(SID("foo")).string());
      });

      it("class selector parse",{
        var result = MageCSSParser.parser("package ;.foo {}").mustSuccess();
        result.css[0].selector.string().should.be(SElement(SClass("foo")).string());
      });

      it("attr selector parse",{
        var result = MageCSSParser.parser('package ;[attr="bar"] {}').mustSuccess();
        result.css[0].selector.string().should.be(SElement(SAttr('[attr="bar"]')).string());
      });

      it("attr selector parse",{
        var result = MageCSSParser.parser('package ;[attr="bar"] {}').mustSuccess();
        result.css[0].selector.string().should.be(SElement(SAttr('[attr="bar"]')).string());
      });

      it("connect class selector parse",{
        var result = MageCSSParser.parser('package ;div.hoge.fuga {}').mustSuccess();
        result.css[0].selector.string().should.be(SElement(SConnect(STag("div"),["hoge","fuga"])).string());
      });

      it("descendant selector parse",{
         var result = MageCSSParser.parser('package ;ul li {}').mustSuccess();
         result.css[0].selector.string().should.be(SDescendant(SElement(STag("ul")),SElement(STag("li"))).string());
      });

      it("deeps child selector parse",{
         var result = MageCSSParser.parser('package ;ul > li {}').mustSuccess();
         result.css[0].selector.string().should.be(
          SChild(SElement(STag("ul")),SElement(STag("li"))).string());
      });

      it("deeps descendant selector parse",{
         var result = MageCSSParser.parser('package ;ul li a {}').mustSuccess();
         result.css[0].selector.string().should.be(
          SDescendant(SElement(STag("ul")),
            SDescendant(SElement(STag("li")),SElement(STag("a")))).string());
      });



      it("success to parse css",{
        var result = MageCSSParser.parser(
"
package sample.package;

div {
  top : 10px;
}

.foo div {
  color : red;
  position : absolute;
}

ul .hoge.fuga {
  color : blue;
}
"
            ).mustSuccess();

            result.cssPackage.should.be("sample.package");
            result.css[0].selector.string().should.be(SElement(STag("div")).string());
            result.css[0].blocks[0].string().should.be({ property : "top", value : "10px" }.string());
            result.css[1].selector.string().should.be(
              SDescendant(SElement(SClass("foo")),SElement(STag("div"))).string()
              );
            result.css[1].blocks[0].string().should.be({ property : "color", value : "red" }.string());
            result.css[1].blocks[1].string().should.be({ property : "position", value : "absolute" }.string());
            result.css[2].selector.string().should.be(
              SDescendant(SElement(STag("ul")),SElement(SConnect(SClass("hoge"),["fuga"]))).string()
              );
      	});
    });
  }
}