package org.farmcode.display.assets
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.instanceFactory.IInstanceFactory;

	public interface IDisplayAsset extends IAsset
	{
		/**
		 * This allows the DelayedDrawer stuff to work. When it gets refactored we can change
		 * this logic to something more like isDescendant(asset:IAsset).
		 */
		function get drawDisplay():DisplayObject;
		
		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
		
		function set scaleX(value:Number):void;
		function get scaleX():Number;
		
		function set scaleY(value:Number):void;
		function get scaleY():Number;
		
		function set width(value:Number):void;
		function get width():Number;
		
		function set height(value:Number):void;
		function get height():Number;
		
		function set rotation(value:Number):void;
		function get rotation():Number;
		
		function get mouseX():Number;
		function get mouseY():Number;
		
		function get naturalWidth():Number;
		function get naturalHeight():Number;
		
		function set visible(value:Boolean):void;
		function get visible():Boolean;
		
		function set name(value:String):void;
		function get name():String;
		
		function set alpha(value:Number):void;
		function get alpha():Number;
		
		function set blendMode(value:String):void;
		function get blendMode():String;
		
		function set scrollRect(value:Rectangle):void;
		function get scrollRect():Rectangle;
		
		function set forceTopLeft(value:Boolean):void;
		function get forceTopLeft():Boolean;
		
		function get stage():IStageAsset;
		function get parent():IContainerAsset;
		
		/**
		 * handler(e:Event, from:IAsset)
		 */
		function get addedToStage():IAct;
		/**
		 * handler(e:Event, from:IAsset)
		 */
		function get removedFromStage():IAct;
		/**
		 * handler(e:Event, from:IAsset)
		 */
		function get added():IAct;
		/**
		 * handler(e:Event, from:IAsset)
		 */
		function get removed():IAct;
		/**
		 * handler(e:Event, from:IAsset)
		 */
		function get enterFrame():IAct;
		
		function position(x:Number, y:Number, width:Number, height:Number):void;
		function globalToLocal(point:Point):Point;
		function localToGlobal(point:Point):Point;
		function getBounds(space:IDisplayAsset):Rectangle;
		
		function getCloneFactory():IInstanceFactory;
	}
}