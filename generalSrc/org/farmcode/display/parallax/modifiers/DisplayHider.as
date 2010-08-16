package org.farmcode.display.parallax.modifiers
{
	import org.farmcode.display.parallax.IParallaxDisplay;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class DisplayHider implements IParallaxModifier
	{
		public function get screenRect():Rectangle{
			return _screenRect;
		}
		public function set screenRect(value:Rectangle):void{
			if(_screenRect!=value){
				_screenRect = value;
			}
		}
		
		private var _screenRect:Rectangle;
		private var _cacheContainer:DisplayObjectContainer;
		private var _boundsCache:Dictionary = new Dictionary();
		
		public function DisplayHider(screenRect:Rectangle=null){
			_screenRect = screenRect;
		}
		public function modifyContainer(container:DisplayObjectContainer):void{
			if(_cacheContainer!=container){
				_boundsCache = new Dictionary();
				_cacheContainer = container;
			}
		}
		public function modifyItem(item:IParallaxDisplay, container:DisplayObjectContainer):void{
			if(_screenRect){
				var display:DisplayObject = item.display;
				var transPoint:Point = new Point();//TODO: pooling
				var subject:DisplayObject = display;
				while(subject!=container){
					transPoint.x *= subject.scaleX;
					transPoint.y *= subject.scaleY;
					transPoint.x += subject.x;
					transPoint.y += subject.y;
					subject = subject.parent;
				}
				
				var bounds:Rectangle = _boundsCache[display];
				if(bounds){
					bounds.x += transPoint.x;
					bounds.y += transPoint.y;
				}else{
					_boundsCache[display] = bounds = display.getBounds(container);
				}
				if(_screenRect.intersects(bounds)){
					if(!display.visible){
						display.visible = true;
					}
				}else if(display.visible){
					display.visible = false;
				}
				bounds.x -= transPoint.x;
				bounds.y -= transPoint.y;
			}
		}
		
	}
}