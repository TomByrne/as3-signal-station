package org.tbyrne.display.progress
{
	import org.tbyrne.display.assets.nativeTypes.ISprite;

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(mainClasspath: String=null){
			super(mainClasspath,new SimpleProgressDisplay(nativeFactory.createContainer()),false);
		}
	}
}