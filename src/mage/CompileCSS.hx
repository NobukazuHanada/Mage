package mage;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Compiler;
import sys.io.File;


class CompileCSS{
	public static var cssCode = "";

	@:build public static function generate(inputText:String){
		var outputText = MageCSSPreprocessor.preprocess(inputText);
		var outputPathArray = Compiler.getOutput().split("/");
		outputPathArray.pop();
		var fname =   outputPathArray.join("/") + "mage.css";
		CompileCSS.cssCode += outputText;
		var fout = File.write( fname, false );
		fout.writeString(CompileCSS.cssCode);
		fout.close();
		return Context.getBuildFields();
	}
}
#end 
