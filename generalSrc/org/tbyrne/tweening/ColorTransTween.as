package org.tbyrne.tweening
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import flash.utils.Dictionary;

	public class ColorTransTween extends AbstractTween
	{
		private static const TRANS_PROPS:Array = ["alphaMultiplier","alphaOffset",
													"redMultiplier","redOffset",
													"greenMultiplier","greenOffset",
													"blueMultiplier","blueOffset"];
		
		
		public function get target():DisplayObject{
			return _target;
		}
		public function set target(value:DisplayObject):void{
			_target = value;
		}
		
		
		public function get startTransform():ColorTransform{
			return _startTransform;
		}
		public function set startTransform(value:ColorTransform):void{
			_startTransform = value;
		}
		
		
		public function get destTransform():ColorTransform{
			return _destTransform;
		}
		public function set destTransform(value:ColorTransform):void{
			_destTransform = value;
		}
		
		private var _applyTransform:ColorTransform = new ColorTransform();
		private var _destTransform:ColorTransform;
		private var _startTransform:ColorTransform;
		private var _target:DisplayObject;
		
		private var _realStart:Dictionary;
		private var _realChange:Dictionary;
		
		public function ColorTransTween(target:DisplayObject=null, destTransform:ColorTransform=null, easing:Function=null, duration:Number=NaN, useFrames:Boolean=false){
			if(target)this.target = target;
			if(destTransform)this.destTransform = destTransform;
			if(easing!=null)this.easing = easing;
			if(!isNaN(duration))this.duration = duration;
			this.useFrames = useFrames;
		}
		
		override public function start() : Boolean {
			super.start();
			_realStart = new Dictionary();
			_realChange = new Dictionary();
			var startMarix:ColorTransform = (_startTransform?_startTransform:target.transform.colorTransform);
			for each(var prop:String in TRANS_PROPS){
				var dest:Number = _destTransform[prop];
				var start:Number = startMarix[prop];
				_realStart[prop] = start;
				
				if(useRelative){
					_realChange[prop] = dest;
				}else{
					_realChange[prop] = dest-start;
				}
			}
			return true;
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			for each(var prop:String in TRANS_PROPS){
				var value:Number = _realStart[prop]+(_realChange[prop]*position);
				if(useRounding)value = Math.round(value);
				_applyTransform[prop] = value;
			}
			target.transform.colorTransform = _applyTransform;
		}
	}
}