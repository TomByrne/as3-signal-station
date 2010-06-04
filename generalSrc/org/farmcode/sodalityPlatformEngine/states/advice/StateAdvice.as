package org.farmcode.sodalityPlatformEngine.states.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityPlatformEngine.states.StateObject;
	import org.farmcode.sodalityPlatformEngine.states.adviceTypes.IStateAdvice;

	public class StateAdvice extends Advice implements IStateAdvice
	{
		[Property(toString="true",clonable="true")]
		public var stateId:String;
		
		private var _stateObject:StateObject;
		private var _stateObjectPath:String;
		
		[Property(toString="true",clonable="true")]
		public function get stateObjectPath():String{
			return _stateObjectPath;
		}
		public function set stateObjectPath(value:String):void{
			_stateObjectPath = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get stateObject():StateObject{
			return _stateObject;
		}
		public function set stateObject(value:StateObject):void{
			_stateObject = value;
		}
		
		
		public function StateAdvice(stateId:String = null, stateObjectPath:String=null, stateObject:StateObject=null){
			this.stateId = stateId;
			this.stateObjectPath = stateObjectPath;
			this.stateObject =stateObject;
		}
		override protected function _execute(cause:IAdvice, time:String):void{
			stateObject.setCurrentState(stateId, this);
			adviceContinue();
		}
		public function get resolvePaths():Array{
			return _stateObject?[]:[_stateObjectPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			var stateObject:StateObject = value[_stateObjectPath];
			if(stateObject)this.stateObject = stateObject;
		}
	}
}