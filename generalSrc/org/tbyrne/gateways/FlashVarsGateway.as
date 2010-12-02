package org.tbyrne.gateways
{
	import flash.display.LoaderInfo;
	
	import org.tbyrne.gateways.interpreters.IDataInterpreter;
	import org.tbyrne.gateways.methodCalls.GetPropertyCall;
	import org.tbyrne.gateways.methodCalls.MethodCall;

	public class FlashVarsGateway extends AbstractDataGateway
	{
		public var interpreters:Vector.<IDataInterpreter>
		
		private var parameters:Object;
		private var _lastCast:GetPropertyCall;
		
		public function FlashVarsGateway(){
			super();
			
			parameters = LoaderInfo.getLoaderInfoByDefinition(this).parameters;
			
		}
		override public function shouldExecuteCall(methodCall:MethodCall):Boolean{
			_lastCast = (methodCall as GetPropertyCall);
			return (_lastCast && parameters[_lastCast.propertyName]!=null);
		}
		override protected function doCall(methodCall:MethodCall, params:Array):void{
			if(_lastCast!=methodCall){
				_lastCast = (methodCall as GetPropertyCall);
			}
			finaliseCall(methodCall,parameters[_lastCast.propertyName],methodCall.successHandler,_lastCast.parameters,interpreters);
		}
	}
}