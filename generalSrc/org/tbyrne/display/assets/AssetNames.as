package org.tbyrne.display.assets
{
	import org.tbyrne.display.DisplayNamespace;
	
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
		
		// GridView
		public static const CELL_RENDERER:String = "cellRenderer";
		
		// VideoContainer
		public static const VIDEO_CONTAINER:String = "videoContainer";
		public static const MEDIA_BOUNDS:String = "mediaBounds";
		
		// CascadingMenuBar
		public static const CHILD_LIST:String = "childList";
		
		CONFIG::debug{
			// DebugDisplay
			public static const DEBUG_DISPLAY:String = "debugDisplay";
			
			// DebugDisplay
			public static const DEBUG_GRAPH_DISPLAY:String = "graph";
			
			// DebugGraph
			public static const DEBUG_GRAPH_UPPER_LABEL:String = "upperLabel";
			
			// DebugGraph
			public static const DEBUG_GRAPH_COPY_BUTTON:String = "copyButton";
			
			// DebugItemRenderer
			public static const DEBUG_ITEM_BITMAP:String = "bitmap";
		}
	}
}