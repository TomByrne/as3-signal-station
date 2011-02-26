package org.tbyrne.display.progress
{
	

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(mainClasspath: String=null){
			super(mainClasspath,new SimpleProgressDisplay(nativeFactory.createContainer()),false);
		}
	}
}