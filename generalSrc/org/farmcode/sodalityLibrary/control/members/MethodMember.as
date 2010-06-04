package org.farmcode.sodalityLibrary.control.members
{
	import au.com.thefarmdigital.utils.methodResolver;
	
	public class MethodMember implements IDestinationMember
	{
		public var method:Function;
		public var passValue:Boolean = false;
		
		public function MethodMember(method:Function=null, passValue:Boolean=false){
			this.method = method;
			this.passValue = passValue;
		}
		public function set value(value:*):void{
			if(passValue)method(value);
			else method();
		}
		
		public function get value():*{
			return null;
		}
		
	}
}