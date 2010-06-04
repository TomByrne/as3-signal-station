package org.farmcode.sodalityWebApp.appState.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateMatch;

	public class SetDefaultAppStateAdvice extends SetAppStateAdvice implements IResolvePathsAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get dataPath():String{
			return _dataPath;
		}
		public function set dataPath(value:String):void{
			_dataPath = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			_data = value;
		}
		override public function get appStateMatch():AppStateMatch{
			var ret:AppStateMatch = super.appStateMatch;
			if(ret && _dataPath){
				if(!ret.parameters)ret.parameters = new Dictionary();
				ret.parameters["*"] = _dataPath;
			}
			return ret;
		}
		
		private var _data:*;
		private var _dataPath:String;
		
		public function SetDefaultAppStateAdvice(stateId:String=null, parameters:Object=null){
			super(stateId, parameters);
		}
		public function get resolvePaths():Array{
			return _data?[]:[_dataPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			data = value[_dataPath];
		}
		
	}
}