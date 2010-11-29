package org.tbyrne.gateways
{
	import org.tbyrne.gateways.interpreters.IDataInterpreter;
	import org.tbyrne.gateways.methodCalls.CallMapping;
	import org.tbyrne.gateways.methodCalls.MethodCall;
	
	public class AbstractFunctionalDataGateway extends AbstractDataGateway
	{
		public function get callMappings():Vector.<CallMapping>{
			return _callMappings;
		}
		public function set callMappings(value:Vector.<CallMapping>):void{
			if(_callMappings!=value){
				_callMappings = value;
				_lastCallMapping = null;
			}
		}
		
		private var _lastCallMapping:CallMapping;
		private var _callMappings:Vector.<CallMapping>;
		
		
		
		public function AbstractFunctionalDataGateway(){
		}
		override public function shouldExecuteCall(methodCall:MethodCall):Boolean{
			if(_lastCallMapping && methodCall is _lastCallMapping.methodClass){
				return true;
			}
			_lastCallMapping = findMapping(methodCall);
			return (_lastCallMapping!=null);
		}
		override protected function doCall(methodCall:MethodCall, params:Array):void{
			if(!_lastCallMapping || !(methodCall is _lastCallMapping.methodClass)){
				_lastCallMapping = findMapping(methodCall);
			}
			if(params){
				for(var i:int=0; i<params.length; i++){
					var param:* = params[i];
					for each(var interperter:IDataInterpreter in _lastCallMapping.argInterpreters){
						param = interperter.outgoing(param);
					}
					params[i] = param;
				}
			}
			doExternalCall(methodCall, _lastCallMapping, params);
		}
		protected function doExternalCall(methodCall:MethodCall, mapping:CallMapping, params:Array):void{
			// override me
		}
		protected function findMapping(methodCall:MethodCall):CallMapping{
			for each(var mapping:CallMapping in _callMappings){
				if(methodCall is mapping.methodClass){
					return mapping;
				}
			}
			return null;
		}
	}
}