package ;

import mage.CompileHTML;

import buddy.*;
using buddy.Should;
using Std;
using utest.Assert;


@:build(mage.CompileHTML.generate("
  package foo.bar;
  <div class=sample><p class=sample>test</p></div>"))
class SimpleView{}

@:build(mage.CompileHTML.generate("
package foo.bar;

<div class=sample>
  <div id=content ></div>
</div>"))
class SimpleView2{}

@:build(mage.CompileHTML.generate("<div><p>{test}</p></div>"))
class TextBindingView{}

@:build(mage.CompileHTML.generate('<div><input id=input type=text></div>'))
class InputBindingView{}

@:build(mage.CompileHTML.generate('<div><SimpleView id=simpleView /></div>'))
class ComponentDom{}


class TestCompileHTML extends BuddySuite{
  public function new() {
    describe("Test Compile HTML", {

    	it("simple Dom test",{
    		var parentDom = js.Browser.document.createElement("div");
    		var simpleView = new SimpleView();
    		parentDom.appendChild(simpleView.root);
    		parentDom.innerHTML.should.be('<div class="sample foo-bar"><p class="sample foo-bar">test</p></div>');
      	});

      	it("textNode binding test",{
      		var parentDom = js.Browser.document.createElement("div");
      		var textBindingView = new TextBindingView();
      		parentDom.appendChild(textBindingView.root);
          textBindingView.update({ test : "Hello" });
    		  parentDom.innerHTML.should.be("<div><p>Hello</p></div>");

        var test : js.html.Text = textBindingView.test;

    		textBindingView.update({ test : "World!" });
    		parentDom.innerHTML.should.be("<div><p>World!</p></div>");
      	});

        it("textNode construction test",{
          var textBindingView = new TextBindingView();
          textBindingView.test.should.notNull();

         });

      	it("input binding text",{
      		var inputDom  = new InputBindingView();
      		var input  = inputDom.input;

      		var expectedDom = js.Browser.document.createElement("input");
      		expectedDom.setAttribute("type","text");

      		input.nodeName.should.be(expectedDom.nodeName);
      		input.getAttribute("type").should.be(expectedDom.getAttribute("type"));
      	});


        it("Component dom test",{
          var componentDom = new ComponentDom();
          switch(Type.typeof(componentDom.simpleView)){
            case TClass(c) : Type.getClassName(c).should.be("SimpleView");
            case _: Assert.fail("simple view is not class type");
          }
        });
    });
  }
}
