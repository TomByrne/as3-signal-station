package au.com.thefarmdigital.structs{
	import flash.utils.Dictionary;
	
	/**
	 * The URL class can parse and construct URL strings, it currently doesn't 
	 * support the hash portion of the URL.
	 */
	public class URL
	{
		private var _protocol:String;
		private var _domain:String;
		private var _path:String;
		private var _variables:Dictionary;
		
		/** The raw url this represents */
		public function get url():String
		{
			if(_variables){
				var url:String = fullPath;
				var pairs:Array = [];
				for(var i:String in _variables){
					var value:* = _variables[i];
					if(value && value.toString().length)pairs.push(i+"="+value.toString());
				}
				var query:String = "";
				var length:int = pairs.length;
				for(var j:int=0; j<length; ++j){
					if(j) query += "&";
					query += pairs[j];
				}
				if(query.length){
					url += "?"+query;
				}
			}
			return url;
		}
		/** @private */
		public function set url(to:String):void
		{
			reset();
			parse(to, true,true,true,true);
		}
		
		/** The protocol part of the url */
		public function get protocol():String{
			return _protocol;
		}
		/** @private */
		public function set protocol(to:String):void
		{
			parse(to, true,false,false,false);
		}
		
		/** The domain portion of a url */
		public function get domain():String{
			return _domain;
		}
		/** @private */
		public function set domain(to:String):void{
			parse(to, false,true,false,false);
		}
		
		/** The path portion of the url */
		public function get path():String{
			return _path;
		}
		/** @private */
		public function set path(to:String):void{
			parse(to, false,false,true,false);
		}
		
		/** The url without the query string values	*/
		public function get fullPath():String{
			var url:String = "";
			if(_domain){
				if(_protocol)url += _protocol+"://";
				url += _domain;
			}
			if(url.charAt(url.length-1)=="/")url = url.slice(0,url.length-2);
			if(_path && _path!="/"){
				url += (_path.charAt(0)=="/")?_path:"/"+_path;
			}
			return url;
		}
		
		/**	The query string variables for the url */
		public function get variables():Dictionary{
			return _variables;
		}
		/** @private */
		public function set variables(to:*):void{
			if(to is String)parse(to, false,false,false,true);
			else if(to is Dictionary)_variables = to;
		}
		
		
		/**
		 * Creates a new url for the given raw url
		 * 
		 * @param	url		A raw string representation of a url
		 */
		public function URL(url:String = null)
		{
			if(url)this.url = url;
		}
		
		/**
		 * Adds a set of variables for the query string. These can either be of the 
		 * form of a raw String or a dictionairy of value
		 * 
		 * @param	variables	A dictionary or name value pair string of the form
		 * 						name=value&name2=value2
		 */
		public function addVariables(variables:*):void{
			if(variables is String){
				var castStr:String = (variables as String);
				if(castStr.charAt(0)=="?")castStr = castStr.slice(1);
				var parts:Array = castStr.split("&");
				var length:int = parts.length;
				for(var i:int=0; i<length; ++i){
					var part:String = parts[i];
					var key:String = (part.indexOf("=")!=-1)?part.slice(0,part.indexOf("=")):part;
					var value:String = (part.indexOf("=")!=-1)?part.slice(part.indexOf("=")+1):"";
					setVariable(key,value);
				}
			}else if(variables is Dictionary){
				var castDict:Dictionary = (variables as Dictionary);
				for(var j:String in castDict){
					setVariable(j,castDict[j].toString());
				}
			}
		}
		
		/**
		 * Sets a query string variable
		 * 
		 * @param	key		The name of the variable
		 * @param	value	The value of the variable
		 */
		public function setVariable(key:String, value:String = null):void
		{
			if(!_variables)_variables = new Dictionary();
			_variables[key] = value;
		}
		
		/**
		 * Sets the url to empty for all its components
		 */
		public function reset():void
		{
			_protocol = _domain = _path = null;
			_variables = new Dictionary();
		}
		
		/**
		 * Returns the raw url being represented
		 * 
		 * @return	A String representation of the url
		 */
		public function toString():String
		{
			return url;
		}
		
		/**
		 * Determines whether this url equals the given raw url or URL object
		 * 
		 * @param	url		The url to compare. Can be an instance of URL or a raw 
		 * 					string of a url
		 * 
		 * @return	true if the url equals the one given, false if not
		 */
		public function equals(url:*):Boolean
		{
			var str:String;
			if(url is String)str = (url as String);
			else if(url is URL)str = (url as URL).toString();
			else return false;
			return (str==this.toString());
		}
		
		/**
		 * Parses the given raw url in to its components and stores them
		 * 
		 * @param	url				The raw url to parse
		 * @param	takeProtocol	Whether to store the protocol parsed
		 * @param	takeDomain		Whether to store the domain parsed
		 * @param	takePath		Whether to store the path parsed
		 * @param	takeQuery		Whether to store the query string parsed
		 */
		private function parse(url:String, takeProtocol:Boolean, 
		 	takeDomain:Boolean = false, takePath:Boolean = false, 
		 	takeQuery:Boolean = false): void
		{
			if(url){
				var remaining:String = url;
				var index:Number = remaining.indexOf("?");
				if(index!=-1){
					var query:String = remaining.slice(index+1);
					remaining = remaining.slice(0,index);
					if(takeQuery)addVariables(query);
				}
				index = remaining.indexOf("://");
				if(index!=-1){
					if(takeProtocol)_protocol = remaining.slice(0,index);
					remaining = remaining.slice(index+3);
				}
				var dot1Index:Number = remaining.indexOf(".");
				var dot2Index:Number = remaining.indexOf(".",dot1Index);
				index = remaining.indexOf("/");
				if(dot1Index!=-1 && dot2Index!=-1 && ((dot1Index<index && dot2Index<index) || index==-1)){
					if(index!=-1){
						if(takePath)_path = remaining.slice(index+1);
						remaining = remaining.slice(0,index);
					}
					if(remaining.length){
						if(takeDomain)_domain = remaining;
					}
				}else if(takePath){
					_path = remaining;
				}
			}else{
				if(takeQuery)_variables = new Dictionary();
				if(takeProtocol)_protocol = null;
				if(takePath)_path = null;
				if(takeDomain)_domain = null;
			}
		}
	}
}