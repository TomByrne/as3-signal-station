package org.tbyrne.debug.display.assets
{
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.schema.AbstractSchemaAssetFactory;
	import org.tbyrne.display.assets.schema.AbstractSchemaBasedAsset;
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;
	import org.tbyrne.display.assets.schemaTypes.IContainerAssetSchema;
	import org.tbyrne.hoborg.ObjectPool;

	public class DebugAssetFactory extends AbstractSchemaAssetFactory
	{
		
		private var _assetPool:ObjectPool = new ObjectPool(DebugAsset);
		
		public function DebugAssetFactory(containerSchema:IContainerAssetSchema){
			super(containerSchema);
		}
		
		// TODO: pool DebugAsset
		override public function createAssetFromSchema(schema:IAssetSchema):IAsset{
			var ret:DebugAsset = _assetPool.takeObject();
			ret.factory = this;
			ret.schema = schema;
			ret.addChildren(attemptToCreateChildren(schema));
			return ret;
		}
		override public function destroyAsset(asset:IAsset):void{
			var debugAsset:DebugAsset = (asset as DebugAsset);
			debugAsset.factory = null;
			debugAsset.schema = null;
			debugAsset.removeAllChildren();
			_assetPool.releaseObject(debugAsset);
		}
		
		/*override protected function getAssetClass(from:AbstractSchemaBasedAsset):Class{
			return DebugAsset;
		}*/
	}
}