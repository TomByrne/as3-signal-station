package org.farmcode.display.assets.assetTypes
{
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.instanceFactory.IInstanceFactory;

	public interface IDisplayAsset extends IAsset
	{
		/**
		 * This allows the asset (and it's children to be added
		 * to the heirarchy). It is only required if the asset
		 * to which this asset is being added requires it.
		 * The root asset of every skin should support this at least.
		 */
		function get displayObject():DisplayObject;
		
		function set x(value:Number):void;
		function get x():Number;
		
		function set y(value:Number):void;
		function get y():Number;
		
		function set width(value:Number):void;
		function get width():Number;
		
		function set height(value:Number):void;
		function get height():Number;
		
		function set scaleX(value:Number):void;
		function get scaleX():Number;
		
		function set scaleY(value:Number):void;
		function get scaleY():Number;
		
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
		
		function set parent(value:IContainerAsset):void;
		function get parent():IContainerAsset;
		
		function get stage():IStageAsset;
		function get transform():Transform;
		function get bitmapDrawable():IBitmapDrawable;
		
		/**
		 * handler(from:IAsset)
		 */
		function get stageChanged():IAct;
		
		/**
		 * handler(from:IAsset)
		 */
		function get addedToStage():IAct;
		/**
		 * handler(from:IAsset)
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
		
		function setPosition(x:Number, y:Number):void;
		function setSize(width:Number, height:Number):void;
		function setSizeAndPos(x:Number, y:Number, width:Number, height:Number):void;
		
		function globalToLocal(point:Point):Point;
		function localToGlobal(point:Point):Point;
		function getBounds(space:IDisplayAsset):Rectangle;
		
		function getCloneFactory():IInstanceFactory;
	}
}