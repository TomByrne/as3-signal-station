package org.tbyrne.composeLibrary.display2D.types
{
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface ILayeredDisplayTrait extends IDisplayObjectTrait
	{
		
		/**
		 * handler(from:ILayeredDisplayTrait)
		 */
		function get requestRedraw():IAct;
		
		function get layerId():String;
	}
}