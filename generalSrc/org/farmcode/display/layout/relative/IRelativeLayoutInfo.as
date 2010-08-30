package org.farmcode.display.layout.relative
{
	import flash.display.DisplayObject;
	
	import org.farmcode.display.assets.assetTypes.IAsset;
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.layout.core.IConstrainedLayoutInfo;
	import org.farmcode.display.layout.core.ILayoutInfo;

	public interface IRelativeLayoutInfo extends IConstrainedLayoutInfo
	{
		function get relativeTo():IDisplayAsset;
		function get relativeOffsetX():Number;
		function get relativeOffsetY():Number;
		function get keepWithinStageBounds():Boolean;
	}
}