package org.tbyrne.display.assets.nativeTypes
{
	import flash.display.DisplayObject;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.assets.assetTypes.IBaseDisplayAsset;
	import org.tbyrne.instanceFactory.IInstanceFactory;

	public interface IDisplayObject extends IBaseDisplayAsset
	{
		
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
		
		function set name(value:String):void;
		function get name():String;
		
		function set alpha(value:Number):void;
		function get alpha():Number;
		
		function set mask(value:IDisplayObject):void;
		function get mask():IDisplayObject;
		
		function set blendMode(value:String):void;
		function get blendMode():String;
		
		function set scrollRect(value:Rectangle):void;
		function get scrollRect():Rectangle;
		
		function set parent(value:IDisplayObjectContainer):void;
		function get parent():IDisplayObjectContainer;
		
		function set filters(value:Array):void;
		function get filters():Array;
		
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
		 * handler(from:IAsset)
		 */
		function get enterFrame():IAct;
		
		function setPosition(x:Number, y:Number):void;
		function setSize(width:Number, height:Number):void;
		function setSizeAndPos(x:Number, y:Number, width:Number, height:Number):void;
		
		function globalToLocal(point:Point):Point;
		function localToGlobal(point:Point):Point;
		function getBounds(space:IDisplayObject):Rectangle;
		
		function getCloneFactory():IInstanceFactory;
	}
}