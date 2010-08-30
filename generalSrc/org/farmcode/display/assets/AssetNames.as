package org.farmcode.display.assets
{
	import org.farmcode.display.DisplayNamespace;
	
	use namespace DisplayNamespace;
	
	public class AssetNames
	{
		// ContainerView
		public static const BACKING:String = "backing";
		
		// TextLabel
		public static const LABEL_FIELD:String = "labelField";
		
		// AbstractList
		public static const SCROLL_BAR:String = "scrollBar";
		public static const LIST_ITEM:String = "listItem";
		
		// VideoContainer
		public static const VIDEO_CONTAINER:String = "videoContainer";
		
		// CascadingMenuBar
		public static const CHILD_LIST:String = "childList";
		
		Config::DEBUG{
			// DebugDisplay
			public static const DEBUG_DISPLAY:String = "debugDisplay";
			
			// DebugItemRenderer
			public static const DEBUG_ITEM_BITMAP:String = "bitmap";
		}
	}
}