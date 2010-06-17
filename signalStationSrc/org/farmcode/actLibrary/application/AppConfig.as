package org.farmcode.actLibrary.application
{
	public class AppConfig implements IAppConfig
	{
		[Property(toString="true",clonable="true")]
		public function get initActs():Array{
			return _initActs;
		}
		public function set initActs(value:Array):void{
			_initActs = value;
		}
		
		// this is here to allow content to be added in SiteStream XML
		public function get data():Array{
			return null;
		}
		public function set data(value:Array):void{
		}
		
		private var _initActs:Array;
	}
}