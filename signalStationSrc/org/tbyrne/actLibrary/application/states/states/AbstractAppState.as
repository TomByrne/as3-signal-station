package org.tbyrne.actLibrary.application.states.states
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.application.states.AppStateMatch;

	public class AbstractAppState implements IAppState
	{
		public function get id():String{
			return _id;
		}
		public function set id(value:String):void{
			_id = value;
		}
		public function get reactors():Array{
			return _reactors;
		}
		public function set reactors(value:Array):void{
			_reactors = value;
		}
		
		private var _id:String;
		private var _reactors:Array;
		
		public function AbstractAppState(stateId:String=null){
			id = stateId;
		}
		public function match(path:String):AppStateMatch{
			return null;
		}
		public function reconstitute(match:AppStateMatch):String{
			return match.parameters?match.parameters["*"]:null;
		}
		protected function getBaseParams(path:String):Dictionary{
			var params:Dictionary = new Dictionary();
			params["*"] = path;
			return params;
		}
	}
}