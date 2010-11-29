package org.tbyrne.gateways
{
	import org.tbyrne.gateways.methodCalls.MethodCall;
	import org.tbyrne.gateways.methodCalls.MethodResult;
	import org.tbyrne.gateways.methodCalls.CallMapping;
	import org.tbyrne.gateways.interpreters.IDataInterpreter;
	
	import flash.events.Event;
	
	import org.swxformat.SWX;
	import org.swxformat.events.SWXFaultEvent;
	import org.swxformat.events.SWXResultEvent;
	import org.swxformat.events.SWXTimeoutEvent;
	import org.tbyrne.utils.MethodCallQueue;
	import org.tbyrne.utils.methodClosure;
	
	public class SWXDataGateway extends AbstractFunctionalDataGateway
	{
		
		/**
		 * in seconds
		 */
		public function get timeout():Number{
			return _swx.timeout;
		}
		public function set timeout(value:Number):void{
			_swx.timeout = value;
		}
		
		public function get debug():Boolean{
			return _swx.debug;
		}
		public function set debug(value:Boolean):void{
			_swx.debug = value;
		}
		
		public function get gatewayURL():String{
			return _swx.gateway;
		}
		public function set gatewayURL(value:String):void{
			_swx.gateway = value;
			if(value){
				recheckReadiness();
			}
		}
		
		private var _swx:SWX;
		
		public function SWXDataGateway(timeout:Number=NaN){
			_swx = new SWX();
			_swx.encoding = SWX.POST;
			this.timeout = timeout;
		}
		override protected function isReady(methodCall:MethodCall):Boolean{
			return (gatewayURL!=null)
		}
		override protected function doExternalCall(methodCall:MethodCall, mapping:CallMapping, params:Array):void{

			var callDetails:Object = {
				serviceClass: mapping.service,
					method: mapping.externalMethodName,
					args: params
			}
			callDetails.resultHandler = methodClosure(resultHandler,methodCall,mapping,params);
			callDetails.timeoutHandler = methodClosure(timeoutHandler,methodCall,mapping,params);
			callDetails.faultHandler = methodClosure(faultHandler,methodCall,mapping,params);
			
			_swx.call(callDetails);
		}
		protected function resultHandler(e:SWXResultEvent, methodCall:MethodCall, mapping:CallMapping, interprettedParams:Array):void{
			if(e.result.status==false){
				finaliseCall(methodCall, e.result, methodCall.faultHandler, interprettedParams, mapping.errorInterpreters);
			}else{
				finaliseCall(methodCall, e.result, methodCall.successHandler, interprettedParams, mapping.resultInterpreters);
			}
		}
		protected function faultHandler(e:SWXFaultEvent, methodCall:MethodCall, mapping:CallMapping, interprettedParams:Array):void{
			finaliseCall(methodCall, e.fault, methodCall.faultHandler, interprettedParams, mapping.errorInterpreters);
		}
		protected function timeoutHandler(e:SWXTimeoutEvent, methodCall:MethodCall, mapping:CallMapping, interprettedParams:Array):void{
			finaliseCall(methodCall, new Error("SWX call timed out"), methodCall.faultHandler, interprettedParams);
		}
	}
}