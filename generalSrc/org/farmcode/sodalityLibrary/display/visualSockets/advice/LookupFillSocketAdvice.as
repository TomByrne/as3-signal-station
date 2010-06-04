package org.farmcode.sodalityLibrary.display.visualSockets.advice
{
	import flash.utils.Dictionary;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.sodalityLibrary.external.siteStream.adviceTypes.IResolvePathsAdvice;

	public class LookupFillSocketAdvice extends FillSocketAdvice implements IResolvePathsAdvice
	{
		
		[Property(toString="true",clonable="true")]
		public function get dataPath():String{
			return _dataPath;
		}
		public function set dataPath(value:String):void{
			if(_dataPath != value){
				dataProvider = null;
				_dataPath = value;
			}
		}
		
		private var _dataPath:String;
		
		public function LookupFillSocketAdvice(displayPath:String=null, dataPath:String = null){
			super(displayPath);
			this.dataPath = dataPath;
		}
		public function get resolvePaths():Array{
			return dataProvider?[]:[_dataPath];
		}
		public function set resolvedObjects(value:Dictionary):void{
			Cloner.setPropertyInClones(this,"resolvedObjects",value);
			dataProvider = value[_dataPath];
		}
	}
}