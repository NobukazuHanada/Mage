package ;

import mage.MageCSS;
import mage.MageCSSPreprocessor;
import mage.MageCSSParser;
import simple.monads.Result;
import simple.monads.Parser;

import buddy.*;
using buddy.Should;
using Std;
using TestUtil;



class TestMageCSSPreprocessor extends BuddySuite implements Buddy {
  public function new() {
    describe("Mage CSSPreprocessor", {
      it("only tag selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;div {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("div.a-b{}");
      });

      it("only class selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;.hoge {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be(".hoge.a-b{}");
      });

      it("only id selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#hoge {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#hoge.a-b{}");
      });

      it("only attr selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;[hoge=fuga] {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("[hoge=fuga].a-b{}");
      });

      it("classConnect selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga.foo.bar {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.foo.bar.a-b{}");
      });

      it("descendant selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga .foo.bar {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b .foo.bar.a-b{}");
      });

      it("child selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga > .foo.bar {}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b > .foo.bar.a-b{}");
      });

      it("use '>'' selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga > .foo.bar #hoge.fuga{}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b > .foo.bar.a-b #hoge.fuga.a-b{}");
      });

      it("use '+' selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga + .foo.bar #hoge.fuga{}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b + .foo.bar.a-b #hoge.fuga.a-b{}");
      });

      it("use '~' selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga ~ .foo.bar #hoge.fuga{}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b ~ .foo.bar.a-b #hoge.fuga.a-b{}");
      });

      it("use ',' selector css",{
        var cssCodeData = MageCSSParser.parser("package a.b;#fuga, .foo.bar #hoge.fuga{}").mustSuccess();
        MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be("#fuga.a-b , .foo.bar.a-b #hoge.fuga.a-b{}");
      });


      it("make new css code",{
          var cssCodeData = MageCSSParser.parser(
"package sample.package;

p {
  color : red;
}

ul > li.active a {
  background-color : blue;
}"
            ).mustSuccess();
        

          MageCSSPreprocessor.evalMageCSS(cssCodeData).should.be(
            "p.sample-package{color:red;}ul.sample-package > li.active.sample-package a.sample-package{background-color:blue;}");
        });
    });
  }
}