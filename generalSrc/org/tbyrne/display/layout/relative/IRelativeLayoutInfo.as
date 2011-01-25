package org.tbyrne.display.layout.relative
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.layout.core.IConstrainedLayoutInfo;
	import org.tbyrne.display.layout.core.ILayoutInfo;

	public interface IRelativeLayoutInfo extends IConstrainedLayoutInfo
	{
		function get relativeTo():IDisplayObject;
		function get relativeOffsetX():Number;
		function get relativeOffsetY():Number;
		function get keepWithinStageBounds():Boolean;
	}
}