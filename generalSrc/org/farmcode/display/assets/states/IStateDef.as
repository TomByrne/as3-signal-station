package org.farmcode.display.assets.states
{
	import org.farmcode.acting.actTypes.IAct;
	

	public interface IStateDef
	{
		/**
		 * handler(from:IStateDef)
		 */
		function get selectionChanged():IAct;
		
		function get selection():int;
		function get options():Array; // of strings
		
		function get stateChangeDuration():Number;
		function set stateChangeDuration(value:Number):void;
	}
}