package org.tbyrne.display.assets.schema
{
	import org.tbyrne.display.assets.schemaTypes.IBitmapAssetSchema;

	public class BitmapAssetSchema extends AbstractDisplayAssetSchema implements IBitmapAssetSchema
	{
		public function get width():Number{
			return _width;
		}
		public function set width(value:Number):void{
			_width = value;
		}
		
		public function get height():Number{
			return _height;
		}
		public function set height(value:Number):void{
			_height = value;
		}
		
		private var _height:Number;
		private var _width:Number;
		
		public function BitmapAssetSchema(assetName:String=null, x:Number=NaN, y:Number=NaN, width:Number=NaN, height:Number=NaN, fallbackToGroup:Boolean=false)
		{
			super(assetName, x, y, fallbackToGroup);
			this.width = width;
			this.height = height;
		}
	}
}