package org.farmcode.tweening
{
	import org.farmcode.hoborg.IPoolable;
	import org.goasap.GoEngine;
	import org.goasap.items.LinearGo;
	import org.goasap.managers.OverlapMonitor;
	

	public class AbstractTween extends LinearGo
	{
		{
			GoEngine.addManager( new OverlapMonitor() );
		}
		
		public function AbstractTween(){
			
		}
	}
}