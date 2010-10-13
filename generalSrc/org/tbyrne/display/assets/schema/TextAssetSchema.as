package org.tbyrne.display.assets.schema
{
	import org.tbyrne.display.assets.schemaTypes.ITextAssetSchema;
	
	public class TextAssetSchema extends AbstractDisplayAssetSchema implements ITextAssetSchema
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
		
		public function get initialText():String{
			return _initialText;
		}
		public function set initialText(value:String):void{
			_initialText = value;
		}
		
		private var _initialText:String;
		private var _height:Number;
		private var _width:Number;
		
		public function TextAssetSchema(assetName:String=null, x:Number=NaN, y:Number=NaN, width:Number=NaN, height:Number=NaN, initialText:String=null, fallbackToGroup:Boolean=false){
			super(assetName, x, y, fallbackToGroup);
			this.width = width;
			this.height = height;
			this.initialText = initialText;
		}
	}
}