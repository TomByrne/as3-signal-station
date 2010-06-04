package org.farmcode.display.layout.stage
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.layout.AbstractLayout;

	public class StageFillLayout extends AbstractLayout
	{
		
		public function get stage():IStageAsset{
			return _stage;
		}
		public function set stage(value:IStageAsset):void{
			if(_stage!=value){
				if(_stage){
					_stage.resize.removeHandler(onStageResize);
				}
				_stage = value;
				if(_stage){
					_stage.resize.addHandler(onStageResize);
					onStageResize();
				}
			}
		}
		
		private var _stage:IStageAsset;
		private var _stageSize:Rectangle = new Rectangle();
		
		public function StageFillLayout(stage:IStageAsset=null){
			super();
			this.stage = stage;
		}
		protected function onStageResize(e:Event=null, from:IStageAsset=null) : void{
			_displayPosition.width = _stage.stageWidth;
			_displayPosition.height = _stage.stageHeight;
			invalidateAll();
		}
	}
}