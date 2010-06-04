package au.com.thefarmdigital.utils
{
	import flash.utils.Dictionary;
	
	public class SimpleContext
	{
		/** The sole instance of the application context */
		public static function get instance():SimpleContext{
			return _instance;
		}
		private static var _instance:SimpleContext;
		
		private static const BASE_URL: String = "baseURL";
		
		/** The baseURL variable passed to the application */
		public function get baseURL():String{
			return getValue(SimpleContext.BASE_URL);
		}
		
		/** The parameter values passed in to the application */
		protected var values:Dictionary;
		
		/** Default parameter values returned if no overriding value is found */
		protected var defaultValues:Dictionary;
		
		/** Values trappes separately to other values; they represent urls */
		protected var urlValues:Dictionary;
		
		protected var parameters: Object;
		
		/**
		 * Creates a new context for the application. Creating a context registers
		 * it as the sole Context instance for the application. An attempt to 
		 * instantiate multiple contexts for an applicaiton will result in a run 
		 * time error.
		 * 
		 * @param	loaderInfo	Information from the application's loading.
		 */
		public function SimpleContext(parameters: Object)
		{
			super();
			if (!_instance)
			{
				_instance = this;
			}
			else
			{
				throw new Error("only one Context should be instantiated per app");
			}
			
			this.parameters = parameters;
			values = new Dictionary();
			defaultValues = new Dictionary();
			urlValues = new Dictionary();
			for(var i:String in this.parameters){
				values[i.toLowerCase()] = this.parameters[i];
			}
		}
		
		public function setDefaultBaseURL(baseURL: String): void
		{
			this.setDefaultValue(SimpleContext.BASE_URL, baseURL);
		}
		
		/**
		 * Retrieve a parameter value from the context.
		 * 
		 * @param	key		The name/identifier of the parameter
		 * 
		 * @return	The value passed in for the parameter or the registered default 
		 * 			value
		 */ 
		public function getValue(key:String):String{
			var ret:String = values[key.toLowerCase()];
			return ret && ret.length?ret:defaultValues[key.toLowerCase()];
		}
		
		public function hasValue(key:String): Boolean{
			var val: String = this.getValue(key);
			return (val != null);
		}
		
		/**
		 * Sets the value to be returned if no value was passed in
		 * 
		 * @param	key		The identifier of the value
		 * @param	value	The value to set as default
		 */
		public function setDefaultValue(key:String, value:String, onlyIfNotSet:Boolean=false):void{
			key = key.toLowerCase();
			if(!defaultValues[key] || !onlyIfNotSet){
				defaultValues[key] = value;
			}
		}
		
		/**
		 * Registers the given url for the context.
		 * 
		 * @param	key		The url identifier
		 * @param	value	The url to store
		 */
		public function setURLValue(key:String, value:String):void{
			urlValues[key.toLowerCase()] = value;
		}
		
		/**
		 * Retrieve the first url found in the context for the given keys. The keys
		 * are searched from first to last to find a registered url.
		 * 
		 * @param	keys	The order to look for the url in. 
		 * @return	The registered url found or null if no url found.
		 */
		public function getURL(keys:Array):String{
			while(keys.length){
				var key:String = keys.pop();
				var url:String = urlValues[key.toLowerCase()];
				if(url)return assemblePath(url);
			}
			return null;
		}
		
		/**
		 * Creates an absolute url out of the given path.
		 * 
		 * @param	path	A relative filepath
		 * @return	The assembled path
		 */
		private function assemblePath(path:String):String{
			var char:String = path.charAt(0);
			if(char=="/" || char=="\\")path = path.slice(1);
			var baseURL:String = this.baseURL;
			char = baseURL.charAt(baseURL.length-1);
			if(char=="/" || char=="\\")baseURL = baseURL.slice(0,baseURL.length-1);
			return baseURL+"/"+path;
		}
	}
}