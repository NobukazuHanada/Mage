package mage;

import htmlparser.HtmlDocument;
import htmlparser.HtmlNodeElement;
import htmlparser.HtmlNodeText;
import htmlparser.HtmlNode;
import haxe.macro.Expr;
import haxe.macro.Context;

using Type;
using StringTools;

class CompileHTML{
	macro public static function generate(s:String):Array<Field>{
		var vars = [];
		var mageVars = [];
		var mageEventVars = [];
		function compileText(text : String){
			var varMatcher = ~/{{[^}]*}}/;
			return if( varMatcher.match(text) ){
				var matchedPos = varMatcher.matchedPos();
				var matchedText = varMatcher.matched(0);
				var varName = matchedText.substring(2, matchedText.length-2).ltrim().rtrim();
				var leftString = text.substring(0,matchedPos.pos);
				var rightString = text.substring(matchedPos.pos + matchedText.length);

				var exprs = [macro {
						this.$varName = js.Browser.document.createTextNode($i{varName});
						this.$varName;
					}];
				vars.push(varName);

				if( leftString.length != 0 )
					exprs.push(macro js.Browser.document.createTextNode($v{leftString}));

				if( rightString.length != 0 ){
					exprs.concat(compileText(rightString));
				}

				return exprs;
			}else [macro js.Browser.document.createTextNode($v{text})];
		}

		function compileNode(node:HtmlNode){
			if(node.getClass().getClassName() == "htmlparser.HtmlNodeText"){
				var nodeText : HtmlNodeText = cast node;
				var text = nodeText.text;
				return compileText(text);
			}else{
				var nodeElement : HtmlNodeElement = cast node;
				var name =  nodeElement.name;
				var domNameExpr = macro var element = js.Browser.document.createElement($v{name});
				var attributes = nodeElement.attributes;
				var attrExprs = attributes.map(function(a){
					return if(a.name == "mage-var"){
							mageVars.push(a.value);
							var value = a.value;
							macro this.$value = element;
						}else{
							macro element.setAttribute($v{a.name},$v{a.value});
						}
					});		
				var domExprs = [domNameExpr].concat(attrExprs);
				var children = nodeElement.nodes;
				var childrenExpr = children.map(function(c) 
					return macro $b{compileNode(c).map(function(c)return macro element.appendChild($c))});
				return [macro $b{domExprs.concat(childrenExpr).concat([macro element])}];
			}
		}

		var htmlDocument = new HtmlDocument(s);
		var firstNode = htmlDocument.nodes[0];
		var nodesExpr = compileNode(firstNode);

		var fields = Context.getBuildFields();

		var newFunction : Function =  {
			ret : null,
			expr : (macro { 
				this.nodes  = [];
				$b{nodesExpr.map(function(e) return macro this.nodes.push($e))}
			}),
			args : vars.map(function(name) : FunctionArg return { name : name, value : null, type : null, opt : null })
		}

		var varsField = vars.concat(mageVars).map(function(v) return {
				name : v,
				doc : null,
				meta : [],
				access : [APublic],
				kind : FVar(macro : js.html.Node),
				pos : Context.currentPos()
			});
		fields = fields.concat(varsField);

		var nodeField = {
			name : "nodes",
			doc : null,
			meta : [],
			access : [APublic],
			kind : FVar(macro : Array<js.html.Node>),
			pos : Context.currentPos()
		}
		fields.push(nodeField);

		var newfield = {
	      name: "new",
	      doc: null,
	      meta: [],
	      access: [APublic],
	      kind: FFun(newFunction),
	      pos: Context.currentPos()
	    };
	    fields.push(newfield);


		return fields;
	}
}