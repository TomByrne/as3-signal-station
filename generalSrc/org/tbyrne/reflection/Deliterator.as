package org.tbyrne.reflection
{
	public class Deliterator
	{
		protected static const NAN:String = "NaN";
		protected static const BOOLEAN_TRUE:String = "true";
		protected static const BOOLEAN_FALSE:String = "false";
		
		protected static const QUOTED:RegExp = /^(?:'(.*)')|(?:"(.*)")$/;
		
		protected static const NUMBER:RegExp = /^(\d+)?\.?\d+$/;
		protected static const NUMBER_16:RegExp = /^((#)|(0x))[0-9A-F]*$/;
		protected static const ARRAY:RegExp = /^\[((?:.+?,)*(?:.+?)?)\]$/;
		protected static const ARRAY_INNER:RegExp = /[^,]+/g;
		protected static const OBJECT:RegExp = /^{((?:[\w.]+:.+,)*(?:[\w.]+:.+))}$/;
		protected static const OBJECT_INNER:RegExp = /([\w.]+?):([^,]+)/g;
		protected static const EXPRESSION:RegExp = /^{.*}$/;
		
		public static function deliterate(string:String, unquote:Boolean=false):*{
			if(unquote){
				var results:Object = QUOTED.exec(string);
				if(results){
					string = results[1];
				}
			}
			if(string==NAN){
				return NaN;
			}else if(string.toLowerCase()==BOOLEAN_TRUE){
				return true;
			}else if(string.toLowerCase()==BOOLEAN_FALSE){
				return false;
			}else if(NUMBER.test(string)){
				return parseFloat(string);
			}else if(NUMBER_16.test(string)){
				return parseInt(string,16);
			}else{
				results = ARRAY.exec(string);
				if(results){
					string = results[1];
					results = ARRAY_INNER.exec(string);
					var retArray:Array = [];
					while(results){
						retArray.push(deliterate(results[0]));
						results = ARRAY_INNER.exec(string)
					}
					return retArray;
				}else{
					results = OBJECT.exec(string)
					if(results){
						string = results[1];
						results = OBJECT_INNER.exec(string)
						var retObject:Object = {};
						while(results){
							retObject[results[1]] = deliterate(results[2]);
							results = OBJECT_INNER.exec(string)
						}
						return retObject;
					}
				}
			}
			return string;
		}

	}
}