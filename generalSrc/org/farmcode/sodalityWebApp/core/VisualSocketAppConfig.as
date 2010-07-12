package org.farmcode.sodalityWebApp.core
{
	import org.farmcode.sodalityLibrary.core.StateAppConfig;

	public class VisualSocketAppConfig extends StateAppConfig implements IVisualSocketAppConfig
	{
		
		[Property(toString="true",clonable="true")]
		public function get rootDataPath():String{
			return _rootDataPath;
		}
		public function set rootDataPath(value:String):void{
			_rootDataPath = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get rootDataMappers():Array{
			return _rootDataMappers;
		}
		public function set rootDataMappers(value:Array):void{
			_rootDataMappers = value;
		}
		
		private var _rootDataMappers:Array;
		private var _rootDataPath:String;
		
	}
}