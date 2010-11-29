package org.tbyrne.gateways.methodCalls
{
	import org.tbyrne.gateways.interpreters.IDataInterpreter;

	public class CallMapping
	{
		public var methodClass:Class;
		public var service:String;
		public var externalMethodName:String;
		public var argInterpreters:Vector.<IDataInterpreter>;
		public var resultInterpreters:Vector.<IDataInterpreter>;
		public var errorInterpreters:Vector.<IDataInterpreter>;
		
		/**
		 * 
		 * @param methodClass
		 * @param service
		 * @param externalMethodName
		 * @param argInterpreters should be a Vector.<IDataInterpreter> or Array of IDataInterpreters
		 * @param resultInterpreters should be a Vector.<IDataInterpreter> or Array of IDataInterpreters
		 * @param errorInterpreters should be a Vector.<IDataInterpreter> or Array of IDataInterpreters
		 * 
		 */
		public function CallMapping(methodClass:Class=null, service:String=null, externalMethodName:String=null,
										  argInterpreters:*=null, resultInterpreters:*=null, errorInterpreters:*=null){
			this.methodClass = methodClass;
			this.service = service;
			this.externalMethodName = externalMethodName;
			
			
			this.argInterpreters = coerceDataVector(argInterpreters);
			this.resultInterpreters = coerceDataVector(resultInterpreters);
			this.errorInterpreters = coerceDataVector(errorInterpreters);
		}
		
		private function coerceDataVector(interpreters:*):Vector.<IDataInterpreter>{
			if(interpreters is Array){
				interpreters = Vector.<IDataInterpreter>(interpreters);
			}
			return (interpreters as Vector.<IDataInterpreter>);
		}
		
	}
}