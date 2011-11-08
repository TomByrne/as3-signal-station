package org.tbyrne.composeLibrary.display2D.types
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface ILayerSortingTrait
	{
		
		/**
		 * handler(from:ILayeredDisplay, layerId:String)
		 */
		function get moveUp():IAct;
		/**
		 * handler(from:ILayeredDisplay, layerId:String)
		 */
		function get moveDown():IAct;
		/**
		 * handler(from:ILayeredDisplay, layerId:String)
		 */
		function get moveToTop():IAct;
		/**
		 * handler(from:ILayeredDisplay, layerId:String)
		 */
		function get moveToBottom():IAct;
		/**
		 * handler(from:ILayeredDisplay, layerId:String, aboveLayerId:String)
		 */
		function get moveAbove():IAct;
		/**
		 * handler(from:ILayeredDisplay, layerId:String, belowLayerId:String)
		 */
		function get moveBelow():IAct;
	}
}