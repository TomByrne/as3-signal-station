package org.tbyrne.gateways.interpreters
{
	public class DataInterpreterGroup implements IDataInterpreter
	{
		private var interpreters:Vector.<IDataInterpreter>;
		
		
		/**
		 * 
		 * @param interpreters should be a Vector.<IDataInterpreter> or Array of IDataInterpreters
		 * 
		 */
		public function DataInterpreterGroup(interpreters:*){
			this.interpreters = coerceDataVector(interpreters);
		}
		private function coerceDataVector(interpreters:*):Vector.<IDataInterpreter>{
			if(interpreters is Array){
				interpreters = Vector.<IDataInterpreter>(interpreters);
			}
			return (interpreters as Vector.<IDataInterpreter>);
		}
		
		public function incoming(data:*):*{
			for each(var interpreter:IDataInterpreter in interpreters){
				data = interpreter.incoming(data);
			}
			return data;
		}
		
		public function outgoing(data:*):*{
			for each(var interpreter:IDataInterpreter in interpreters){
				data = interpreter.outgoing(data);
			}
			return data;
		}
	}
}