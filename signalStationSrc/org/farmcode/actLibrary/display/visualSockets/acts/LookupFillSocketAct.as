package org.farmcode.actLibrary.display.visualSockets.acts
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.external.siteStream.actTypes.IResolvePathsAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class LookupFillSocketAct extends FillSocketAct implements IResolvePathsAct
	{
		public function get dataPath():String{
			return _dataPath;
		}
		public function set dataPath(value:String):void{
			if(_dataPath != value){
				dataProvider = null;
				_dataPath = value;
			}
		}
		
		public function get resolveSuccessful():Boolean{
			return _resolveSuccessful;
		}
		public function set resolveSuccessful(value:Boolean):void{
			_resolveSuccessful = value;
		}
		
		private var _resolveSuccessful:Boolean;
		private var _dataPath:String;
		
		public function LookupFillSocketAct(displayPath:String=null, dataPath:String = null){
			super(displayPath);
			this.dataPath = dataPath;
		}
		public function get resolvePaths():Array{
			return dataProvider?[]:[_dataPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			dataProvider = value[_dataPath];
		}
	}
}