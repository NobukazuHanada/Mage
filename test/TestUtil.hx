package ;

import simple.monads.Parser;
import simple.monads.Result;
using Std;

class TestUtil{
	public static function mustSuccess<T,A,B>(result : ParseResult<A,B,T>) : T 
          return switch (result) {
            case Success(ParseItem(p,_)): p;
            case Error(message): throw "not success, in success context : Error message " + message.string();
          };

    
}