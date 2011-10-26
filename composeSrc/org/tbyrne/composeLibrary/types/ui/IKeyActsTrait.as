package org.tbyrne.composeLibrary.types.ui
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.compose.traits.ITrait;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	
	public interface IKeyActsTrait extends ITrait
	{
		function getKeyIsDown(keyCode:uint, keyLocation:int=-1):IBooleanProvider;
		function getCharIsDown(charCode:uint):IBooleanProvider;
		
		/**
		 * handler(from:IMouseActsTrait, actInfo:IKeyActInfo)
		 */
		function get keyPressed():IAct;
		
		/**
		 * handler(from:IMouseActsTrait, actInfo:IKeyActInfo)
		 */
		function get keyReleased():IAct;
	}
}