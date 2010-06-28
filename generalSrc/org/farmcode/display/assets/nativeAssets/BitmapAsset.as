package org.farmcode.display.assets.nativeAssets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.IBitmapAsset;
	
	public class BitmapAsset extends DisplayObjectAsset implements IBitmapAsset
	{
		override public function set displayObject(value:DisplayObject):void{
			if(super.displayObject!=value){
				super.displayObject = value;
				if(value){
					_bitmap = value as Bitmap;
				}else{
					_bitmap = null;
				}
			}
		}
		
		protected var _bitmap:Bitmap;
		
		public function BitmapAsset()
		{
			super();
		}
		
		public function get bitmapData():BitmapData{
			return _bitmap.bitmapData;
		}
		public function set bitmapData(value:BitmapData):void{
			_bitmap.bitmapData = value;
		}
		
		public function get pixelSnapping():String{
			return _bitmap.pixelSnapping;
		}
		public function set pixelSnapping(value:String):void{
			_bitmap.pixelSnapping = value;
		}
		
		public function get smoothing():Boolean{
			return _bitmap.smoothing;
		}
		public function set smoothing(value:Boolean):void{
			_bitmap.smoothing = value;
		}
	}
}