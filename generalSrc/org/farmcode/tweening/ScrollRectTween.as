package org.farmcode.tweening
{
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class ScrollRectTween extends AbstractBlurTween
	{
		
		public function get target():DisplayObject{
			return _blurTarget;
		}
		public function set target(value:DisplayObject):void{
			_blurTarget = value;
		}
		public function get destRect():Rectangle{
			return _destRect;
		}
		public function set destRect(value:Rectangle):void{
			if(_destRect != value){
				_destRect = value;
			}
		}
		
		private var _destRect:Rectangle;
		
		private var _startRect:Rectangle;
		private var _changeRect:Rectangle;
		private var _applyRect:Rectangle;
		
		private var displayTarget: DisplayObject;
		
		public function ScrollRectTween(target: DisplayObject, easing: Function, destRect: Rectangle, duration: Number, useFrames: Boolean = false, blurAmount:Number = 0)
		{
			super();
			this.destRect = destRect;
			this.duration = duration;
			this.target = target;
			this.easing = easing;
			this.useFrames = useFrames;
			this.blurAmount = blurAmount;
		}
		override public function start() : Boolean {
			_startRect = target.scrollRect;
			if(!_startRect){
				_startRect = _destRect.clone();
				_startRect.x = 0;
				_startRect.y = 0;
			}
			_changeRect = _destRect.clone();
			if(!useRelative){
				_changeRect.x -= _startRect.x;
				_changeRect.y -= _startRect.y;
				_changeRect.width -= _startRect.width;
				_changeRect.height -= _startRect.height;
			}
			_totalChangeX = _changeRect.x;
			_totalChangeY = _changeRect.y;
			
			_applyRect = new Rectangle();
			
			return super.start();
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			_applyRect.x = _startRect.x+(position*_changeRect.x);
			_applyRect.y = _startRect.y+(position*_changeRect.y);
			_applyRect.width = _startRect.width+(position*_changeRect.width);
			_applyRect.height = _startRect.height+(position*_changeRect.height);
			
			target.scrollRect = _applyRect;
		}
	}
}