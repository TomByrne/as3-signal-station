package org.tbyrne.display.assets.nativeAssets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	
	public class BitmapAsset extends DisplayObjectAsset implements IBitmap
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
		
		public function BitmapAsset(factory:NativeAssetFactory=null){
			super(factory);
		}
		
		public function get bitmapData():BitmapData{
			return _bitmap.bitmapData;
		}
		public function set bitmapData(value:BitmapData):void{
			_bitmap.bitmapData = value;
		}
		
		public function get bitmapPixelSnapping():String{
			return _bitmap.pixelSnapping;
		}
		public function set bitmapPixelSnapping(value:String):void{
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