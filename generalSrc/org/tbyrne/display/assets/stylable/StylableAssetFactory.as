package org.tbyrne.display.assets.stylable
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.schema.AbstractSchemaAssetFactory;
	import org.tbyrne.display.assets.schema.AbstractSchemaBasedAsset;
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;
	import org.tbyrne.display.assets.schemaTypes.IContainerAssetSchema;
	import org.tbyrne.hoborg.ObjectPool;
	
	public class StylableAssetFactory extends AbstractSchemaAssetFactory
	{
		
		public function get textStyles():Array{
			return _textStyles;
		}
		public function set textStyles(value:Array):void{
			if(_textStyles!=value){
				_textStyles = value;
				for(var i:* in _assets){
					i.textStyles = value;
				}
			}
		}
		public function get rectangleStyles():Array{
			return _rectangleStyles;
		}
		public function set rectangleStyles(value:Array):void{
			if(_rectangleStyles!=value){
				_rectangleStyles = value;
				for(var i:* in _assets){
					i.rectangleStyles = value;
				}
			}
		}
		
		private var _rectangleStyles:Array;
		private var _textStyles:Array;
		
		private var _assetPool:ObjectPool = new ObjectPool(StylableAsset);
		private var _assets:Dictionary = new Dictionary(true);
		
		public function StylableAssetFactory(containerSchema:IContainerAssetSchema){
			super(containerSchema);
		}
		
		// TODO: pool DebugAsset
		override public function createAssetFromSchema(schema:IAssetSchema):IAsset{
			var ret:StylableAsset = _assetPool.takeObject();
			ret.factory = this;
			ret.schema = schema;
			ret.textStyles = _textStyles;
			ret.rectangleStyles = _rectangleStyles;
			ret.addChildren(attemptToCreateChildren(schema));
			_assets[ret] = true;
			return ret;
		}
		override public function destroyAsset(asset:IAsset):void{
			var stylableAsset:StylableAsset = (asset as StylableAsset);
			stylableAsset.factory = null;
			stylableAsset.schema = null;
			stylableAsset.textStyles = null;
			stylableAsset.rectangleStyles = null;
			stylableAsset.removeAllChildren();
			_assetPool.releaseObject(stylableAsset);
			delete _assets[stylableAsset];
		}
		
		/*override protected function getAssetClass(from:AbstractSchemaBasedAsset):Class{
			return StylableAsset;
		}*/
	}
}