package ;

import mage.CompileHTML;

import buddy.*;
using buddy.Should;
using Std;


@:build(mage.CompileHTML.generate("
  package foo.bar;
  <div class='sample'><p class='sample'>test</p></div>"))
class SimpleView{}

@:build(mage.CompileHTML.generate("<div><p>{{test}}</p></div>"))
class TextBindingView{}

@:build(mage.CompileHTML.generate('<div><input type="text" mage-var="input"/></div>'))
class InputBindingView{}

class TestCompileHTML extends BuddySuite implements Buddy {
  public function new() {
    describe("Test Compile HTML", {

    	it("simple Dom test",{
    		var parentDom = js.Browser.document.createElement("div");
    		var simpleView = new SimpleView();
    		parentDom.appendChild(simpleView.nodes[0]);
    		parentDom.innerHTML.should.be('<div class="sample foo-bar"><p class="sample foo-bar">test</p></div>');
      	});

      	it("textNode binding test",{
      		var parentDom = js.Browser.document.createElement("div");
      		var textBindingView = new TextBindingView("Hello");
      		parentDom.appendChild(textBindingView.nodes[0]);
    		parentDom.innerHTML.should.be("<div><p>Hello</p></div>");

        var test : js.html.Text = textBindingView.test;

    		textBindingView.test.nodeValue = "World!";
    		parentDom.innerHTML.should.be("<div><p>World!</p></div>");
      	});

      	it("input binding text",{
      		var inputDom  = new InputBindingView();
      		var input  = inputDom.input;

      		var expectedDom = js.Browser.document.createElement("input");
      		expectedDom.setAttribute("type","text");

      		input.nodeName.should.be(expectedDom.nodeName);
      		input.getAttribute("type").should.be(expectedDom.getAttribute("type"));
      	});
    });
  }
}
