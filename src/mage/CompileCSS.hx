package mage;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Compiler;
import sys.io.File;


class CompileCSS{
	public static var cssCode = "";

	public static function generate(inputText:String){
		
		
		var outputText = MageCSSPreprocessor.proprocess(inputText);
		var fname = "mage.css";
		CompileCSS.cssCode += outputText;
		var fout = File.write( fname, false );
		fout.writeString(CompileCSS.cssCode);
		fout.close();

		return Context.getBuildFields();
	}
}
#end 
