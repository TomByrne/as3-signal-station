package org.tbyrne.display.progress
{
	import org.tbyrne.display.assets.assetTypes.ISpriteAsset;

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(mainClasspath: String=null){
			super(mainClasspath,new SimpleProgressDisplay(nativeFactory.createContainer()),false);
		}
	}
}