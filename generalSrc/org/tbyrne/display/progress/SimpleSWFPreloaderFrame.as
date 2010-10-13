package org.tbyrne.display.progress
{
	import org.tbyrne.display.assets.assetTypes.ISpriteAsset;

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(){
			super(null,new SimpleProgressDisplay(nativeFactory.createContainer()),false);
		}
	}
}