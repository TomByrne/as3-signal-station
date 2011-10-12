package org.tbyrne.input.menu
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IStringProvider;

	public interface IMenuInputItem extends IControlData
	{
		/**
		 * handler(from:IMenuInputItem)
		 */
		function get shownInMenuChanged():IAct;
		function get shownInMenu():Boolean;
		
		/**
		 * handler(from:IMenuInputItem)
		 */
		function get menuLocationChanged():IAct;
		function get menuLocation():String;
	}
}