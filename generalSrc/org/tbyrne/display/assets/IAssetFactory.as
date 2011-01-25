package org.tbyrne.display.assets
{
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IBitmap;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.ISprite;

	public interface IAssetFactory
	{
		function getCoreSkin(coreSkinLabel:String):IAsset;
		
		//function createAsset(type:Class):*;
		
		function createContainer():IDisplayObjectContainer;
		function createBitmap():IBitmap;
		function createHitArea():ISprite;
		function destroyAsset(asset:IAsset):void;
	}
}