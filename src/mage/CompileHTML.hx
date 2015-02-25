package mage;

import haxe.macro.Expr;
import haxe.macro.Context;
import mage.MageHtmlParser.Node;
import simple.monads.Result;
import simple.monads.Parser.ParseItem;

using Type;
using StringTools;
using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

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
		

		function compileNode(node) : Array<Expr>{
			return switch(node){
				case E(name,attributes,childNodes):
					var typeDom = elementNameToType(name);

					// createDom Exprs
					var createDomExprs = if( isUpperCaseFirstChar(name) ){
						var newClassType = { name : name, pack : []};
						[(macro var component : $typeDom = new $newClassType()),
						 (macro var element = component.root)];
					}else
					[macro var element : $typeDom =cast js.Browser.document.createElement($v{name})];
					
					/// attributes expr
					var attrExprs = attributes.map(function(attr) 
						return macro element.setAttribute($v{attr.key},$v{attr.value}));
					if(packageClass != null && packageClass != "")
						attrExprs.push(macro element.classList.add($v{packageClass}));

					// catch id doms expr
					var catchDomExprs = [];
					for( attr in attributes ){
						if( attr.key == "id" ){
							var varname = attr.value;
							mageVars.push({name : varname, type : typeDom});
							var expr = if( isUpperCaseFirstChar(name) )
					 			 macro this.$varname = component
					 		else
					 			 macro this.$varname = element;
					 		
					 		catchDomExprs.push(expr);
						}
					}

					var domExprs = createDomExprs.concat(catchDomExprs).concat(attrExprs);
					var childrenExpr = childNodes.map(function(c) 
					 	return macro $b{compileNode(c).map(function(c)
					 		return if(c != null) macro element.appendChild($c)
					 		else macro null)});
					[macro $b{domExprs.concat(childrenExpr).concat([macro element])}];
				case Text(text):
					[macro js.Browser.document.createTextNode($v{text})];
				case MageText(varname):
					var textDom = macro : js.html.Text;
					vars.push(varname);
					mageVars.push({name : varname, type : textDom });
					[macro {
						if( initValue != null && initValue.$varname != null )
						this.$varname = js.Browser.document.createTextNode(initValue.$varname)
						else 
						this.$varname = js.Browser.document.createTextNode("");
						this.$varname;
					}];
				case CommentOut: [];
			}
		}
		

	 
		var htmlNode = switch(mage.MageHtmlParser.parse(htmlCode)){
			case Success(ParseItem(htmlNode,_)):htmlNode;
			case Error(error) : null;
			case _ : null;
		}
		if( htmlNode == [] ){
			throw "parse error";
		}
		var nodesExpr = compileNode(htmlNode[0]);
		var fields = Context.getBuildFields();



		var initType : ComplexType = ComplexType.TAnonymous(vars.map(function(vname)
			return (({
				name : vname,
				pos : Context.currentPos(),
				kind : FVar(macro : String),
				meta : [{pos:Context.currentPos(), name : ":optional", params : [] }]
			}) : Field)
		));


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

		var rootField = {
			name : "root",
			doc : null,
			meta : [],
			access : [APublic],
			kind : FVar(roottype(htmlNode[0])),
			pos : Context.currentPos()
		}
		fields.push(rootField);

		fields = new_function_create(fields,nodesExpr,vars,initType);

		return fields;
	}

	#if macro
	private static function new_function_create(fields : Array<Field>, nodesExpr, vars, initType) : Array<Field>{
		var new_func = null;
		var new_expr = null;
		var new_args = [];

		for( f in fields ){
			switch (f) {
				case {
					name:"new", 
					pos:_pos, 
					kind:FFun({
						args : args,
						expr : expr
						})
					}:
					new_func = f;
					new_args = args;
					new_expr = expr;
				case _: null;
			}
		}

		if( new_func != null ){
			fields.remove(new_func);
		}

		var newFunction : Function =  {
			ret : null,
			expr : if( new_func == null ) macro { 
				this.nodes  = [];
				$b{nodesExpr.map(function(e) return macro this.nodes.push($e))}
				this.root = cast this.nodes[0];
			} else macro { 
				this.nodes  = [];
				$b{nodesExpr.map(function(e) return macro this.nodes.push($e))}
				this.root = cast this.nodes[0];
				$new_expr;
			},
			args : if(vars.length == 0 ) new_args else new_args.concat([{ name : "initValue", value : null, type : initType, opt : true }])
		}

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
	#end

	#if macro
	private static function roottype(node:Node){
		return switch (node) {
			case E(name,_,_):elementNameToType(name);
			case _ : macro : js.html.Text;
		};
	}
	#end

	#if macro
	private static function isUpperCaseFirstChar(s : String){
		return s.charCodeAt(0) >= "A".charCodeAt(0) && s.charCodeAt(0) <= "Z".charCodeAt(0);
	}
	#end

	#if macro
	private static function elementNameToType(s:String) : ComplexType
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
				case tag : if( isUpperCaseFirstChar(tag) ){
					   TPath({name : tag, pack : [], params : []});
					}
					else macro : js.html.Element;
			};
		#end
}