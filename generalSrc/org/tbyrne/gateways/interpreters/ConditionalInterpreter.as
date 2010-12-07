package org.tbyrne.gateways.interpreters
{
	public class ConditionalInterpreter implements IDataInterpreter
	{
		public static var ALWAYS_CONDITION:Function;
		{
			ALWAYS_CONDITION = function(data:*):Boolean{return true};
		}
		
		
		public var returnNullByDefault:Boolean;
		
		private var _incoming:Vector.<InterpreterBundle>;
		private var _outgoing:Vector.<InterpreterBundle>;
		
		public function ConditionalInterpreter(returnNullByDefault:Boolean=false)
		{
			this.returnNullByDefault = returnNullByDefault;
		}
		
		public function addInterpreter(condition:Function, interpreter:IDataInterpreter):*{
			if(!_incoming){
				_incoming = new Vector.<InterpreterBundle>();
			}
			if(!_outgoing){
				_outgoing = new Vector.<InterpreterBundle>();
			}
			var bundle:InterpreterBundle = new InterpreterBundle(condition,interpreter);
			_incoming.push(bundle);
			_outgoing.push(bundle);
		}
		public function addIncomingInterpreter(condition:Function, interpreter:IDataInterpreter):*{
			if(!_incoming){
				_incoming = new Vector.<InterpreterBundle>();
			}
			_incoming.push(new InterpreterBundle(condition,interpreter));
		}
		public function addOutgoingInterpreter(condition:Function, interpreter:IDataInterpreter):*{
			if(!_outgoing){
				_outgoing = new Vector.<InterpreterBundle>();
			}
			_outgoing.push(new InterpreterBundle(condition,interpreter));
		}
		
		public function incoming(data:*):*{
			for each(var bundle:InterpreterBundle in _incoming){
				if(bundle.condition(data)){
					return bundle.interpreter.incoming(data);
				}
			}
			return returnNullByDefault?null:data;
		}
		public function outgoing(data:*):*{
			for each(var bundle:InterpreterBundle in _outgoing){
				if(bundle.condition(data)){
					return bundle.interpreter.outgoing(data);
				}
			}
			return returnNullByDefault?null:data;
		}
	}
}
import org.tbyrne.gateways.interpreters.IDataInterpreter;

class InterpreterBundle{
	public var condition:Function;
	public var interpreter:IDataInterpreter;
	
	public function InterpreterBundle(condition:Function, interpreter:IDataInterpreter){
		this.condition = condition;
		this.interpreter = interpreter;
	}
}