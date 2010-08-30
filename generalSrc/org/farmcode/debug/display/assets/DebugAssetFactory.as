package org.farmcode.debug.display.assets
{
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.schema.AbstractSchemaAssetFactory;
	import org.farmcode.display.assets.schema.AbstractSchemaBasedAsset;
	import org.farmcode.display.assets.schemaTypes.IAssetSchema;
	import org.farmcode.display.assets.schemaTypes.IContainerAssetSchema;

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
		
		override protected function getAssetClass(from:AbstractSchemaBasedAsset):Class{
			return DebugAsset;
		}
	}
}