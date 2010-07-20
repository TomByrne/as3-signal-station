package org.farmcode.tweening
{
	
	public class LooseTween extends AbstractTween
	{
		
		public function get target():Object{
			return _target;
		}
		public function set target(value:Object):void{
			_target = value;
		}
		
		
		public function get startProps():Object{
			return _startProps;
		}
		public function set startProps(value:Object):void{
			_startProps = value;
		}
		
		
		public function get destProps():Object{
			return _destProps;
		}
		public function set destProps(value:Object):void{
			_destProps = value;
		}
		
		private var _destProps:Object;
		private var _startProps:Object;
		private var _target:Object;
		
		private var _realStart:Object;
		private var _realChange:Object;
		
		public function LooseTween(target:Object=null, destProps:Object=null, easing:Function=null, duration:Number=NaN, useFrames:Boolean=false, useRounding:Boolean=false, useRelative:Boolean=false){
			if(target)this.target = target;
			if(destProps)this.destProps = destProps;
			if(easing!=null)this.easing = easing;
			if(!isNaN(duration))this.duration = duration;
			this.useFrames = useFrames;
			this.useRounding = useRounding;
			this.useRelative = useRelative;
		}
		
		override public function start() : Boolean {
			super.start();
			_realStart = {};
			_realChange = {};
			var execute:Boolean = false;
			for(var prop:String in _destProps){
				var dest:Number = _destProps[prop];
				if(!isNaN(dest)){
					var start:Number = _startProps?_startProps[prop]:NaN;
					if(isNaN(start))start = _target[prop];
					if(isNaN(start))start = 0;
					_realStart[prop] = start;
					
					if(useRelative){
						_realChange[prop] = dest;
					}else{
						_realChange[prop] = dest-start;
					}
					execute = true;
				}
			}
			return execute;
		}
		override protected function onUpdate(type : String) : void{
			super.onUpdate(type);
			for(var prop:String in _realStart){
				var value:Number = _realStart[prop]+(_realChange[prop]*position);
				if(useRounding)value = Math.round(value);
				target[prop] = value;
			}
		}
	}
}