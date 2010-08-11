package org.farmcode.tweening
{
	
	import flash.geom.Rectangle;

	public class RectangleTween extends AbstractTween
	{
		public function get destRect():Rectangle{
			return _destRect;
		}
		public function set destRect(value:Rectangle):void{
			_destRect = value;
		}
		public function get startRect():Rectangle{
			return _startRect;
		}
		public function set startRect(value:Rectangle):void{
			_startRect = value;
		}
		public function get currentRect():Rectangle{
			return _currentRect;
		}
		
		
		private var _destRect:Rectangle;
		private var _startRect:Rectangle;
		private var _changeRect:Rectangle;
		private var _currentRect:Rectangle;
		private var _starting:Boolean;
		
		public function RectangleTween(startRect:Rectangle, easing:Function, destRect:Rectangle, duration:Number, useFrames:Boolean = false){
			super();
			this.startRect = startRect;
			this.destRect = destRect;
			this.duration = duration;
			this.easing = easing;
			this.useFrames = useFrames;
		}
		override public function start() : Boolean {
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
			
			_currentRect = new Rectangle();
			
			_starting = true;
			var ret:Boolean = super.start();
			_starting = false;
			return ret;
		}
		override protected function onUpdate(type : String) : void{
			_currentRect.x = _startRect.x+(position*_changeRect.x);
			_currentRect.y = _startRect.y+(position*_changeRect.y);
			_currentRect.width = _startRect.width+(position*_changeRect.width);
			_currentRect.height = _startRect.height+(position*_changeRect.height);
			
			super.onUpdate(type);
		}
		override public function stop():Boolean{
			if(!_starting && _currentFrame){
				_startRect = _currentRect.clone();
			}
			return super.stop();
		}
	}
}