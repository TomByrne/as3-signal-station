package org.tbyrne.actLibrary.logging
{
	import org.tbyrne.acting.acts.UniversalAct;
	
	public class LogAct extends UniversalAct implements ILogAct
	{
		
		public function get level():int{
			return _level;
		}
		public function set level(value:int):void{
			_level = value;
		}
		
		public function get params():Array{
			return _params;
		}
		public function set params(value:Array):void{
			_params = value;
		}
		
		private var _params:Array;
		private var _level:int;
		
		public function LogAct(){
			super();
		}
	}
}