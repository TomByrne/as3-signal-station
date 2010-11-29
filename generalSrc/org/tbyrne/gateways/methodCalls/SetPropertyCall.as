package org.tbyrne.gateways.methodCalls
{
	public class GetPropertyCall extends MethodCall
	{
		public function get parameters():Array{
			return [propertyName, newValue];
		}
		
		public var propertyName:String;
		public var newValue:*;
		
		public function GetPropertyCall(propertyName:String=null, newValue:*=null){
			super();
			this.propertyName = propertyName;
			this.newValue = newValue;
		}
	}
}