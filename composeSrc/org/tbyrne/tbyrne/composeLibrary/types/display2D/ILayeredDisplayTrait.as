package org.tbyrne.tbyrne.composeLibrary.types.display2D
{
	import org.tbyrne.acting.actTypes.IAct;
	
	public interface ILayeredDisplayTrait extends IDisplayObjectTrait
	{
		
		/**
		 * handler(from:ILayeredDisplay)
		 */
		function get moveUp():IAct;
		/**
		 * handler(from:ILayeredDisplay)
		 */
		function get moveDown():IAct;
		/**
		 * handler(from:ILayeredDisplay)
		 */
		function get moveToTop():IAct;
		/**
		 * handler(from:ILayeredDisplay)
		 */
		function get moveToBottom():IAct;
		/**
		 * handler(from:ILayeredDisplay, aboveLayerId:String)
		 */
		function get moveAbove():IAct;
		/**
		 * handler(from:ILayeredDisplay, belowLayerId:String)
		 */
		function get moveBelow():IAct;
		
		function get layerId():String;
	}
}