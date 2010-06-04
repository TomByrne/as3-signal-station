package au.com.thefarmdigital.tweening
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	
	public class MotionTween extends AbstractBlurTween
	{
		public function get target():DisplayObject{
			return _blurTarget;
		}
		public function set target(value:DisplayObject):void{
			_blurTarget = value;
		}
		
		public function get startX():Number{
			return _startX;
		}
		public function set startX(value:Number):void{
			_startX = value;
		}
		
		public function get destX():Number{
			return _destX;
		}
		public function set destX(value:Number):void{
			_destX = value;
		}
		
		public function get startY():Number{
			return _startY;
		}
		public function set startY(value:Number):void{
			_startY = value;
		}
		
		public function get destY():Number{
			return _destY;
		}
		public function set destY(value:Number):void{
			_destY = value;
		}
		
		
		private var _doX:Boolean;
		private var _destX:Number;
		private var _startX:Number;
		private var _doY:Boolean;
		private var _destY:Number;
		private var _startY:Number
		
		private var _realStartX:Number;
		private var _realStartY:Number;
		
		public function MotionTween(target:DisplayObject=null, destX:Number=NaN, destY:Number=NaN, blurAmount:Number = 0, easing:Function=null, duration:Number=NaN, useFrames:Boolean=false, useRounding:Boolean=false, useRelative:Boolean=false){
			if(target)this.target = target;
			this.destX = destX;
			this.destY = destY;
			if(easing!=null)this.easing = easing;
			if(!isNaN(duration))this.duration = duration;
			this.useFrames = useFrames;
			this.useRounding = useRounding;
			this.useRelative = useRelative;
			this.blurAmount = blurAmount;
		}
		
		override public function start() : Boolean {
			super.start();
			
			if(!isNaN(_destX)){
				_doX = true;
				_realStartX = isNaN(_startX)?target.x:_startX;
				_totalChangeX = _destX-(useRelative?0:_realStartX);
			}else{
				_doX = false;
			}
			if(!isNaN(_destY)){
				_doY = true;
				_realStartY = isNaN(_startY)?target.y:_startY;
				_totalChangeY = _destY-(useRelative?0:_realStartY);
			}else{
				_doY = false;
			}
			
			return true;
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			if(_doX)target.x = _realStartX+(_totalChangeX*position);
			if(_doY)target.y = _realStartY+(_totalChangeY*position);
		}
	}
}