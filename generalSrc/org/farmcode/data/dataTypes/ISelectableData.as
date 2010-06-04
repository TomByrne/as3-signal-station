package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;

	public interface ISelectableData
	{
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		function get selectAct():IAct // (from:ISelectableData, selected:Boolean)
	}
}