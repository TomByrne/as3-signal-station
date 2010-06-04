package org.farmcode.display.layout.relative
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.layout.core.IConstrainedLayoutInfo;

	public interface IRelativeLayoutInfo extends IConstrainedLayoutInfo
	{
		function get relativeTo():DisplayObject;
		function get relativeOffsetX():Number;
		function get relativeOffsetY():Number;
		function get keepWithinStageBounds():Boolean;
	}
}