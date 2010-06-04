package org.farmcode.actLibrary.application.states.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.application.states.AppStateMatch;
	import org.farmcode.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.farmcode.hoborg.Cloner;

	public class LookupSetAppStateAct extends SetAppStateAct implements IResolvePathsAct
	{
		override public function get appStateMatch():AppStateMatch{
			var ret:AppStateMatch = super.appStateMatch;
			if(ret){
				if(!ret.parameters)ret.parameters = new Dictionary();
				for(var i:String in _lookupParams){
					var value:* = _lookupParams[i];
					ret.parameters[i] = value;
				}
			}
			return ret;
		}
		public function get lookupParams():Dictionary{
			return _lookupParams;
		}
		public function set lookupParams(value:Dictionary):void{
			_lookupParams = value;
		}
		
		private var _lookupParams:Dictionary;
		
		public function LookupSetAppStateAct(stateId:String=null, parameters:Object=null){
			super(stateId, parameters);
		}
		public function addLookupParameter(data:*, parameter:String = "*"):void{
			if(!_lookupParams || !_lookupParams[parameter]){
				if(!_lookupParams)_lookupParams = new Dictionary();
				_lookupParams[parameter] = data;
			}else{
				throw new Error("LookupSetAppStateAdvice.addLookupParameter: lookup parameter "+parameter+" has already been added.");
			}
		}
		public function removeLookupParameter(parameter:String = "*"):void{
			delete _lookupParams[parameter];
		}
		public function get resolvePaths():Array{
			var ret:Array = [];
			for(var i:String in _lookupParams){
				if(_lookupParams[i]==null){
					ret.push(i);
				}
			}
			return ret;
		}
		public function set resolvedObjects(value:Dictionary):void{
			for(var i:String in value){
				_lookupParams[i] = value[i];
			}
		}
	}
}