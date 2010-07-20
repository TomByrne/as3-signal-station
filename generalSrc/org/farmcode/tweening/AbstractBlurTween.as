package org.farmcode.tweening
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	
	public class AbstractBlurTween extends AbstractTween
	{
		public function get blurAmount():Number{
			return _blurAmount;
		}
		public function set blurAmount(value:Number):void{
			_blurAmount = value;
		}
		
		protected var _totalChangeX:Number = 0;
		protected var _totalChangeY:Number = 0;
		protected var _blurAmount:Number = 0;
		protected var _blurTarget:DisplayObject;
		protected var _otherFilters:Array;
		protected var _lastPosition:Number = 0;
		
		public function AbstractBlurTween(blurSubject:DisplayObject=null){
			super();
			_blurTarget = blurSubject;
		}
		override public function start() : Boolean {
			super.start();
			_otherFilters = _blurTarget?_blurTarget.filters:null;
			_lastPosition = 0;
			
			return true;
		}
		override public function stop() : Boolean {
			_blurTarget.filters = _otherFilters;
			return super.stop();
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			if(_blurTarget && !isNaN(blurAmount) && blurAmount){
				if(position<1){
					var blurX:Number = Math.abs(_totalChangeX*(position-_lastPosition))*blurAmount;
					var blurY:Number = Math.abs(_totalChangeY*(position-_lastPosition))*blurAmount;
					
					var blur:Number = ((position<0.5)?position*2:1-((position*2)-1));
					var filter:BlurFilter = new BlurFilter(blur*blurX,blur*blurY);
					_blurTarget.filters = _otherFilters.concat([filter]);
				}else{
					_blurTarget.filters = _otherFilters;
				}
			}
			_lastPosition = position;
		}
	}
}