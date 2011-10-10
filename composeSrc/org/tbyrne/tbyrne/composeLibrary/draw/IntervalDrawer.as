package org.tbyrne.tbyrne.composeLibrary.draw
{
	import flash.utils.getTimer;
	
	import org.tbyrne.tbyrne.compose.traits.AbstractTrait;
	import org.tbyrne.tbyrne.composeLibrary.types.draw.IDrawAwareTrait;
	import org.tbyrne.core.EnterFrameHook;

	public class IntervalDrawer extends AbstractTrait
	{
		public function get running():Boolean{
			return _running;
		}
		public function set running(value:Boolean):void{
			if(_running!=value){
				_running = value;
				if(_running){
					_lastFrameTime = getTimer();
					EnterFrameHook.getAct().addHandler(onGameTick);
				}else{
					EnterFrameHook.getAct().removeHandler(onGameTick);
				}
			}
		}
		
		public function get speed():Number{
			return _speed;
		}
		public function set speed(value:Number):void{
			_speed = value;
		}
		
		private var _speed:Number = 1;
		private var _running:Boolean;
		private var _lastFrameTime:int;
		
		public function IntervalDrawer(running:Boolean=false, speed:Number=1){
			this.running = running;
			this.speed = speed;
		}
		protected function onGameTick():void{
			if(_speed!=0){
				var frameTime:int = getTimer();
				var timeStep:Number = (frameTime-_lastFrameTime)/1000*_speed;
				
				var trait:IDrawAwareTrait;
				var traits:Array;
				
				_lastFrameTime = frameTime;
				
				traits = _item.getTraits(IDrawAwareTrait);
				for each(trait in traits){
					trait.tick(timeStep);
				}
				
				if(_group){
					traits = _group.getDescTraits(IDrawAwareTrait);
					for each(trait in traits){
						trait.tick(timeStep);
					}
				}
			}
		}
	}
}