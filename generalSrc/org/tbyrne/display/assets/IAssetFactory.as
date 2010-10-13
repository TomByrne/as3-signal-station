package org.tbyrne.display.assets
{
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IBitmapAsset;
	import org.tbyrne.display.assets.assetTypes.IContainerAsset;
	import org.tbyrne.display.assets.assetTypes.ISpriteAsset;

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