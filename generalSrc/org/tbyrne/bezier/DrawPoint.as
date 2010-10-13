package org.tbyrne.bezier
{
	import org.tbyrne.hoborg.IPoolable;
	
	/**
	 *  For internal use by the bezier class, this is only public to allow for pooling.
	 */
	public class DrawPoint implements IPoolable
	{
		public var method: String;
		public var args: Array;
		
		public function reset():void{
			method = null;
			args = null;
		}
	}
}