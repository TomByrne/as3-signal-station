package org.tbyrne.gateways.methodCalls
{
	public class GetPropertyCall extends MethodCall
	{
		override public function get parameters():Array{
			return [propertyName];
		}
		
		public var propertyName:String;
		
		public function GetPropertyCall(propertyName:String=null){
			super();
			this.propertyName = propertyName;
		}
	}
}