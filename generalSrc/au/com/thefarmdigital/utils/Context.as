package au.com.thefarmdigital.utils
{
	import flash.display.LoaderInfo;
	
	/**
	 * The Context object allows code to discreetly access text variables and urls.
	 * Any variables can be injected via HTML and defaults set up within the 
	 * project. The context is a Singleton implementation, however it requires 
	 * explicit creation. This is done through a 
	 * <code>new Context(loaderInfo)</code> statement. Once a single context has 
	 * been instantiated, the global access to it can be achieved through
	 * Context.instance  
	 */
	public class Context extends SimpleContext
	{
		public static function get instance(): Context
		{
			return SimpleContext.instance as Context;
		}
		
		/**	The loader info used to construct this context */
		protected var loaderInfo:LoaderInfo;
		
		/**
		 * Creates a new context for the application. Creating a context registers
		 * it as the sole Context instance for the application. An attempt to 
		 * instantiate multiple contexts for an applicaiton will result in a run 
		 * time error.
		 * 
		 * @param	loaderInfo	Information from the application's loading.
		 */
		public function Context(loaderInfo:LoaderInfo)
		{
			super(loaderInfo.parameters);
			
			this.loaderInfo = loaderInfo;
		}
	}
}