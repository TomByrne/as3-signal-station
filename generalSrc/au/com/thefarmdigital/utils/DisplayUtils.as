package au.com.thefarmdigital.utils
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IContainerAsset;
	import org.farmcode.display.assets.IDisplayAsset;
	
	/**
	 * Collection of utility functions for display elements
	 */
	public class DisplayUtils
	{
		private static const MULTIPLY: String = "*";
		private static const ADDITION: String = "+";
		
		public static function moveDisplayKeepingProperties(moveDisplay: DisplayObject,
			toContainer: DisplayObjectContainer): void
		{
			var fromContainer: DisplayObjectContainer = moveDisplay.parent;
			
			var originalMatrix: Matrix = moveDisplay.transform.concatenatedMatrix;
			var toMatrix: Matrix = toContainer.transform.concatenatedMatrix;
			
			fromContainer.removeChild(moveDisplay);
			
			var newMatrix: Matrix = originalMatrix.clone();
			toMatrix.invert();
			newMatrix.concat(toMatrix);
			moveDisplay.transform.matrix = newMatrix;
			
			toContainer.addChild(moveDisplay);
		}
		
		/**
		 * Should return the same as target.getBounds(target). However this is sometimes not accurate
		 * e.g. when there is a scrollRect or you've removed a scrollRect this frame
		 */
		public static function getBoundsFromChildren(target: DisplayObjectContainer): Rectangle
		{
			var bounds: Rectangle = new Rectangle();
			for (var i: uint = 0; i < target.numChildren; ++i)
			{
				var child: DisplayObject = target.getChildAt(i);
				
				var proposedX: Number = child.x;
				var proposedY: Number = child.y;
				var proposedRight: Number = child.x;
				var proposedBottom: Number = child.y;
				
				// For some reason, empty displays seem to place themselves at funny coordinates; 
				// or have funny bounds
				if (child.width != 0 || child.height != 0)
				{
					var cBounds: Rectangle = child.getBounds(target);
					proposedX = cBounds.x;
					proposedY = cBounds.y;
					proposedRight = cBounds.right;
					proposedBottom = cBounds.bottom;
				}
				bounds.x = Math.min(bounds.x, proposedX);
				bounds.y = Math.min(bounds.y, proposedY);
				bounds.width = Math.max(bounds.width, proposedRight - bounds.x);
				bounds.height = Math.max(bounds.height, proposedBottom - bounds.y);
			}
			return bounds;
		}
		
		/**
		 * Finds if the given descendant is within the given parent's display tree
		 * 
		 * @param	parent		The object's tree to search within
		 * @param	descendant	The object to search for within the tree
		 * 
		 * @return	true if the descendant was found in the parent's tree, false if not
		 */
		public static function isDescendant(parent:IContainerAsset, decendant:IDisplayAsset):Boolean{
			var subject:IDisplayAsset = decendant;
			while(subject!=decendant.stage){
				subject = subject.parent;
				if(subject==parent)return true;
			}
			return false;
		}
		/**
		 * Executes a function for each descendant of a DisplayObjectContainer (passing the descendant through as the first parameter).
		 * NOTE: The function will be called for the parent object as well.
		 * 
		 * @param	parent		The root of the DisplayObjects
		 * @param	func		The method to call for each DisplayObject (the DisplayObject will be passed through as the first parameter).
		 * @param	ofType		A class that DisplayObjects must implement for the function to be called. Leaving this null will use all DisplayObjects.
		 * @param	topDown		Whether to execute from the top down (true), or the bottom up (false).
		 * 
		 */
		public static function executeForDescendants(parent:IDisplayAsset, func:Function, ofType:Class=null, topDown:Boolean=false):void{
			var typeMatch:Boolean = ofType!=null?(parent is ofType):true;
			if(topDown && typeMatch)func(parent);
			var container:IContainerAsset = (parent as IContainerAsset);
			if(container){
				var length:int = container.numChildren;
				for(var i:int=0; i<length; ++i){
					executeForDescendants(container.getAssetAt(i),func,ofType,topDown);
				}
			}
			if(!topDown && typeMatch)func(parent);
		}
		
		/**
		 * If using a textfield, only seems to work for antialias as animation
		 */
		public static function getOpaqueBounds(display: DisplayObject): Rectangle
		{
			var bmd: BitmapData = new BitmapData(display.width, display.height, true, 0);
			bmd.draw(display);
			
			var bounds: Rectangle = new Rectangle();
			bounds.x = DisplayUtils.getOpaqueSpace(bmd, false, true);
			bounds.y = DisplayUtils.getOpaqueSpace(bmd, true, true);
			bounds.right = display.width - DisplayUtils.getOpaqueSpace(bmd, false, false);
			bounds.bottom = display.height - DisplayUtils.getOpaqueSpace(bmd, true, false);
			bmd.dispose();
			return bounds;
		}
		
		private static function getOpaqueSpace(bmd: BitmapData, vertical: Boolean = true,	
			ascending: Boolean = true): Number
		{
			var primaryAxis: int = bmd.height;
			var secondaryAxis: int = bmd.width;
			if (!vertical)
			{
				primaryAxis = bmd.width;
				secondaryAxis = bmd.height;
			}
			
			var space: Number = 0;
			if (!ascending)
			{
				space = secondaryAxis;
			}
			var colourFound: Boolean = false;
			
			for (var i: uint = 0; i < primaryAxis && !colourFound; ++i)
			{
				for (var j: uint = 0; j < secondaryAxis && !colourFound; ++j)
				{
					var useI: uint = i;
					if (!ascending)
					{
						useI = primaryAxis - i - 1;
					}
					var col: uint;
					var row: uint;
					if (vertical)
					{
						col = j;
						row = useI;						
					}
					else
					{
						row = j;
						col = useI;
					}
					var pix: uint = bmd.getPixel32(col, row);
					if (pix != 0)
					{
						colourFound = true;
						space = i;
					}
				}
			}
			return space;
		}
		
		// TODO: Allow terminalParent to be a non parent of display
		// TODO: Need to take in to account parent scaling
		public static function getRelativeX(display: DisplayObject, terminalParent: DisplayObjectContainer = null): Number
		{
			return DisplayUtils.getCompoundedProperty(display, "x", terminalParent);
		}
		
		// TODO: Need to take in to account parent scaling
		public static function getRelativeY(display: DisplayObject, terminalParent: DisplayObjectContainer = null): Number
		{
			return DisplayUtils.getCompoundedProperty(display, "y", terminalParent);
		}
		
		public static function getGlobalAlpha(display: DisplayObject): Number
		{
			return DisplayUtils.getCompoundedProperty(display, "alpha", null, DisplayUtils.MULTIPLY, 1);
		}
		
		protected static function getCompoundedProperty(display: DisplayObject, property: String, 
			terminalParent: DisplayObjectContainer = null, relation: String = null, 
			startValue: Number = 0): Number
		{
			if (terminalParent == null)
			{
				terminalParent = display.stage;
			}
			
			var value: Number = startValue;
			var p: DisplayObject = display;
			do
			{
				var pValue: * = p[property];
				switch (relation)
				{
					case	DisplayUtils.MULTIPLY:
						value *= pValue;
						break;
					case	DisplayUtils.ADDITION:
					default:
						value += pValue;
				}
				p = p.parent;
			}
			while (p != null && p != terminalParent)
			return value;
		}
	}
}