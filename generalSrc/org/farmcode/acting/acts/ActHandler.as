package org.farmcode.acting.acts
{
	/**
	 * ActHandler is used internally in the act system to track
	 * active handlers and info about them.
	 */
	public class ActHandler{
		private static const pool:Array = new Array();
		public static function getNew(handler:Function, additionalArguments:Array):ActHandler{
			if(pool.length){
				var ret:ActHandler = pool.shift();
				ret.handler = handler;
				ret.additionalArguments = additionalArguments;
				return ret;
			}else{
				return new ActHandler(handler, additionalArguments);
			}
		}
		
		public var handler:Function;
		public var additionalArguments:Array;
		public var executions:int = 0;
		
		public function ActHandler(handler:Function, additionalArguments:Array){
			this.handler = handler;
			this.additionalArguments = additionalArguments;
		}
		public function release():void{
			handler = null;
			additionalArguments = null;
			pool.unshift(this);
		}
	}
}