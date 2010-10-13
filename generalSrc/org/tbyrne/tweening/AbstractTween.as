package org.tbyrne.tweening
{
	import org.tbyrne.hoborg.IPoolable;
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