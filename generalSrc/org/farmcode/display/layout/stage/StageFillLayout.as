package org.farmcode.display.layout.stage
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.layout.AbstractLayout;

	public class StageFillLayout extends AbstractLayout
	{
		
		public function get stage():Stage{
			return _stage;
		}
		public function set stage(value:Stage):void{
			if(_stage!=value){
				if(_stage){
					_stage.removeEventListener(Event.RESIZE, onStageResize);
				}
				_stage = value;
				if(_stage){
					_stage.addEventListener(Event.RESIZE, onStageResize);
					onStageResize();
				}
			}
		}
		
		private var _stage:Stage;
		private var _stageSize:Rectangle = new Rectangle();
		
		public function StageFillLayout(stage:Stage=null){
			super();
			this.stage = stage;
		}
		protected function onStageResize(e:Event=null) : void{
			_displayPosition.width = _stage.stageWidth;
			_displayPosition.height = _stage.stageHeight;
			invalidateAll();
		}
	}
}