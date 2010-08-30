package org.farmcode.display.progress
{
	import org.farmcode.display.assets.assetTypes.ISpriteAsset;

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(){
			super(null,new SimpleProgressDisplay(nativeFactory.getNewByType(ISpriteAsset)),false);
		}
	}
}