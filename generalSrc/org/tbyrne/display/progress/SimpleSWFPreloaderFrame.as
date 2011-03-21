package org.tbyrne.display.progress
{
	

	public class SimpleSWFPreloaderFrame extends SWFPreloaderFrame
	{
		public function SimpleSWFPreloaderFrame(mainClasspath: String=null){
			var progressDisplay:SimpleProgressDisplay = new SimpleProgressDisplay(nativeFactory.createContainer());
			super(mainClasspath,progressDisplay,progressDisplay,false);
		}
	}
}