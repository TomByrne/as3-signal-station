package au.com.thefarmdigital.utils
{
	import flash.events.IEventDispatcher;
	
	/** 
	 * The FlashBinder class mimics the behaviour of the BindingUtils class in the 
	 * Flex SDK.
	 */
	 // TODO: implement Bindable tags using the flash.utils.describeType  or DescribeTypeCache.describeType
	 // functionality of AS3.
	public class FlashBinder
	{
		protected static var bindings:Array = [];
		
		/**
		 * Create a binding for a property
		 * 
		 * @param	destination		The destination object to bind the propery to
		 * @param	prop			The name of the property to place the change in
		 * @param	host			The object with a property to listen to
		 * @param	hostProp		The property to listen to changes on
		 * @param	event			The name of the event triggered when hostProp 
		 * 							changes
		 */
		public static function bindProperty(destination:Object, prop:String, 
			host:IEventDispatcher, hostProp:String, event:String):void
		{
			breakBinding(destination, prop);
			var binding:BindingBundle = new BindingBundle(destination, prop, host, 
				hostProp, event);
				
			host.addEventListener(event,binding.execute);
			bindings.push(binding);
			binding.execute();
		}
		
		/**
		 * Discontinue a binding for a property
		 * 
		 * @param	destination		The destination of the property to break 
		 * 							binding of
		 * @param	prop			The property to break the binding on
		 */
		public static function breakBinding(destination:Object, prop:String): void
		{
				
			var index:Number = findBindingIndex(destination, prop);
			if(index!=-1){
				var binding:BindingBundle = bindings[index];
				binding.host.removeEventListener(binding.event,binding.execute);
				bindings.splice(index,1);
			}
		}
		
		/**
		 * Find the index of the given binding information
		 * 
		 * @param	destination		The destination object for the binding to check
		 * @param	prop			The property whos binding to check for
		 * 
		 * @return	The index of the binding within the bindings array, -1 if not 
		 * 			found
		 */
		private static function findBindingIndex(destination:Object, 
			prop:String):Number
		{
			var length:int = bindings.length;
			for(var i:int=0; i<length; ++i){
				var binding:BindingBundle = bindings[i];
				if(binding.destination==destination && binding.prop==prop){
					return i;
				}
			}
			return -1;
		}
	}
}

import flash.events.Event;
import flash.events.IEventDispatcher;
	
/**
 * @private 
 */
class BindingBundle
{
	public var destination:Object;
	public var prop:String;
	public var host:IEventDispatcher;
	public var hostProp:String;
	public var event:String;
	
	public function BindingBundle(destination:Object, prop:String, 
		host:IEventDispatcher, hostProp:String, event:String)
	{
		this.destination = destination;
		this.prop = prop;
		this.host = host;
		this.hostProp = hostProp;
		this.event = event;
	}
	public function execute(e:Event=null):void{
		destination[prop] = host[hostProp]
	}
}