package org.farmcode.display.controls.toolTip
{
	public interface IToolTipManager
	{
		function addTipTrigger(trigger:IToolTipTrigger):void;
		function removeTipTrigger(trigger:IToolTipTrigger):void;
	}
}