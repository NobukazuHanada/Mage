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
	macro public static function generate(inputText:String):Array<Field>{
		var htmlCodePos = inputText.indexOf("<");
		var headText = inputText.substring(0,htmlCodePos);
		var packageRegExp = ~/package [^;]*;/;
		var packageClass : String = if(packageRegExp.match(headText)){
			 packageRegExp.matched(0).substring(8)
							.replace(" ","")
							.replace(";","")
							.replace(".","-");
		}else "";
		var htmlCode = inputText.substring(htmlCodePos);

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
						this.$varName = js.Browser.document.createTextNode(initValue.$varName);
						this.$varName;
					}];
				
				vars.push(varName);
				var textDom = macro : js.html.Text;
				mageVars.push({name : varName, type : textDom });

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
				var typeDom = elementNameToType(name);
				var domNameExpr = macro var element : $typeDom =cast js.Browser.document.createElement($v{name});
				var attributes = nodeElement.attributes;
				var attrExprs = attributes.map(function(a){
					return if(a.name == "mage-var"){
							mageVars.push({name : a.value, type : typeDom});
							var value = a.value;
							macro this.$value = element;
						}else{
							macro element.setAttribute($v{a.name},$v{a.value});
						}
					});
				if(packageClass != ""){
					attrExprs.push(macro element.classList.add($v{packageClass}));
				}	
				var domExprs = [domNameExpr].concat(attrExprs);
				var children = nodeElement.nodes;
				var childrenExpr = children.map(function(c) 
					return macro $b{compileNode(c).map(function(c)return macro element.appendChild($c))});
				return [macro $b{domExprs.concat(childrenExpr).concat([macro element])}];
			}
		}

		var htmlDocument = new HtmlDocument(htmlCode);
		var firstNode = htmlDocument.nodes[0];
		var nodesExpr = compileNode(firstNode);

		var fields = Context.getBuildFields();

		var newFunction : Function =  {
			ret : null,
			expr : (macro { 
				this.nodes  = [];
				$b{nodesExpr.map(function(e) return macro this.nodes.push($e))}
			}),
			args : if(vars.length == 0 ) [] else [{ name : "initValue", value : null, type : null, opt : null }]
		}

		var mageVarsField = mageVars.map(function(v) return {
				name : v.name,
				doc : null,
				meta : [],
				access : [APublic],
				kind : FVar(v.type),
				pos : Context.currentPos()
			});
		fields = fields.concat(mageVarsField);

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

	#if macro
	private static function elementNameToType(s:String)
			return switch (s) {
				case "a": macro : js.html.AnchorElement;
				case "applet" : macro : js.html.AppletElement;
				case "area" : macro : js.html.AreaElement;
				case "br" : macro : js.html.BRElement;
				case "base" : macro : js.html.BaseElement;
				case "basefont" : macro : js.html.BaseFontElement;
				case "body" : macro : js.html.BodyElement;
				case "button" : macro : js.html.ButtonElement;
				case "canvas" : macro : js.html.CanvasElement;
				case "content" : macro : js.html.ContentElement;
				case "dl" : macro : js.html.DListElement;
				case "datalist" : macro : js.html.DataListElement;
				case "details" : macro : js.html.DetailsElement;
				case "dir" : macro : js.html.DirectoryElement;
				case "div" : macro : js.html.DivElement;
				case "embed" : macro : js.html.EmbedElement;
				case "fieldset" : macro : js.html.FieldSetElement;
				case "font" : macro : js.html.FontElement;
				case "frame" : macro : js.html.FrameElement;
				case "frameset" : macro : js.html.FrameSetElement;
				case "hr" : macro : js.html.HRElement;
				case "head" : macro : js.html.HeadElement;
				case "h1" : macro : js.html.HeadingElement;
				case "h2" : macro : js.html.HeadingElement;
				case "h3" : macro : js.html.HeadingElement;
				case "h4" : macro : js.html.HeadingElement;
				case "h5" : macro : js.html.HeadingElement;
				case "h6" : macro : js.html.HeadingElement;
				case "html" : macro : js.html.HtmlElement;
				case "iframe" : macro : js.html.IFrameElement;
				case "img" : macro : js.html.ImageElement;
				case "input" : macro : js.html.InputElement;
				case "keygen" : macro : js.html.KeygenElement;
				case "li" : macro : js.html.LIElement;
				case "label" : macro : js.html.LabelElement;
				case "legend" : macro : js.html.LegendElement;
				case "link" : macro : js.html.LinkElement;
				case "map" : macro : js.html.MapElement;
				case "marquee" : macro : js.html.MarqueeElement;
				case "audio" : macro : js.html.MediaElement;
				case "video" : macro : js.html.MediaElement;
				case "menu" : macro : js.html.MenuElement;
				case "meta" : macro : js.html.MetaElement;
				case "meter" : macro : js.html.MeterElement;
				case "del" : macro : js.html.ModElement;
				case "ins" : macro : js.html.ModElement;
				case "ol" : macro : js.html.OListElement;
				case "object" : macro : js.html.ObjectElement;
				case "optgroup" : macro : js.html.OptGroupElement;
				case "option" : macro : js.html.OptionElement;
				case "output" : macro : js.html.OutputElement;
				case "p" : macro : js.html.ParagraphElement;
				case "param" : macro : js.html.ParamElement;
				case "pre" : macro : js.html.PreElement;
				case "progress" : macro : js.html.ProgressElement;
				case "q" : macro : js.html.QuoteElement;
				case "script" : macro : js.html.ScriptElement;
				case "select" : macro : js.html.SelectElement;
				case "shadow" : macro : js.html.ShadowElement;
				case "source" : macro : js.html.SourceElement;
				case "span" : macro : js.html.SpanElement;
				case "style" : macro : js.html.StyleElement;
				case "table" : macro : js.html.TableElement;
				case "tbody" : macro : js.html.TableSectionElement;
				case "thead" : macro : js.html.TableSectionElement;
				case "tfoot" : macro : js.html.TableSectionElement;
				case "td" : macro : js.html.TableCellElement;
				case "col" : macro : js.html.TableColElement;
				case "colgroup" : macro : js.html.TableColElement;
				case "tr" : macro : js.html.TableRowElement;
				case "caption" : macro : js.html.TableCaptionElement;
				case "textarea" : macro : js.html.TextAreaElement;
				case "title" : macro : js.html.TitleElement;
				case "track" : macro : js.html.TrackElement;
				case "ul" : macro : js.html.UListElement;
				case _ : macro : js.html.Element;
			};
		#end
}