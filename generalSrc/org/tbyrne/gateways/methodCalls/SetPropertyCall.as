package org.tbyrne.gateways.methodCalls
{
	public class SetPropertyCall extends MethodCall
	{
		override public function get parameters():Array{
			return [propertyName, newValue];
		}
		
		public var propertyName:String;
		public var newValue:*;
		
		public function SetPropertyCall(propertyName:String=null, newValue:*=null){
			super();
			this.propertyName = propertyName;
			this.newValue = newValue;
		}
	}
}