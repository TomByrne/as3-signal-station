package org.tbyrne.debug.display.assets
{
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.schema.AbstractSchemaAssetFactory;
	import org.tbyrne.display.assets.schema.AbstractSchemaBasedAsset;
	import org.tbyrne.display.assets.schemaTypes.IAssetSchema;
	import org.tbyrne.display.assets.schemaTypes.IContainerAssetSchema;

	public class DebugAssetFactory extends AbstractSchemaAssetFactory
	{
		
		public function DebugAssetFactory(containerSchema:IContainerAssetSchema){
			super(containerSchema);
		}
		
		// TODO: pool DebugAsset
		override public function createAssetFromSchema(schema:IAssetSchema):IAsset{
			var ret:DebugAsset = new DebugAsset(this,schema);
			ret.addChildren(attemptToCreateChildren(schema));
			return ret;
		}
		override public function destroyAsset(asset:IAsset):void{
			// ignore (till pooling is added)
		}
		
		override protected function getAssetClass(from:AbstractSchemaBasedAsset):Class{
			return DebugAsset;
		}
	}
}