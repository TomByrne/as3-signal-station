package org.tbyrne.display.assets.schema
{
	import org.tbyrne.display.assets.schemaTypes.IRectangleAssetSchema;
	
	public class RectangleAssetSchema extends ContainerAssetSchema implements IRectangleAssetSchema
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
		
		public function get visible():Boolean{
			return _visible;
		}
		public function set visible(value:Boolean):void{
			_visible = value;
		}
		
		private var _visible:Boolean;
		private var _height:Number;
		private var _width:Number;
		
		public function RectangleAssetSchema(assetName:String=null, x:Number=NaN, y:Number=NaN, width:Number=NaN, height:Number=NaN, childSchemas:Array=null, visible:Boolean=true, fallbackToGroup:Boolean=false){
			super(assetName, x, y, childSchemas, fallbackToGroup);
			this.width = width;
			this.height = height;
			this.visible = visible;
		}
	}
}