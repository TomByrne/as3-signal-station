package org.farmcode.actLibrary.application
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.nativeAssets.NativeAssetFactory;

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
		
		public function get mainAsset():IDisplayAsset{
			return _mainAsset;
		}
		public function set mainAsset(value:IDisplayAsset):void{
			_mainAsset = value;
		}
		
		public function set mainDisplay(value:DisplayObject):void{
			_mainAsset = value?NativeAssetFactory.getNew(value):null;
		}
		
		private var _mainAsset:IDisplayAsset;
		private var _initActs:Array;
	}
}