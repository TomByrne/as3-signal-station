package org.farmcode.display.assets
{
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IBitmapAsset;
	import org.farmcode.display.assets.assetTypes.IContainerAsset;
	import org.farmcode.display.assets.assetTypes.ISpriteAsset;

	public interface IAssetFactory
	{
		function getCoreSkin(coreSkinLabel:String):IAsset;
		
		//function createAsset(type:Class):*;
		
		function createContainer():IContainerAsset;
		function createBitmap():IBitmapAsset;
		function createHitArea():ISpriteAsset;
		function destroyAsset(asset:IAsset):void;
	}
}