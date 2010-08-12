package org.farmcode.display.layout.stage
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractSeperateLayout;
	import org.farmcode.display.layout.ILayoutSubject;

	public class StageFillLayout extends AbstractSeperateLayout
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
		
		public function StageFillLayout(scopeView:IView=null, stage:IStageAsset=null){
			super(scopeView);
			this.stage = stage;
		}
		override protected function drawToMeasure() : Boolean{
			return false;
		}
		override protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			super.onSubjectMeasChanged(from, oldWidth, oldHeight);
			subjMeasurementsChanged(from);
		}
		override protected function measureSubject(subject:ILayoutSubject, subjMeas:Point):void{
			var meas:Point = subject.measurements;
			subjMeas.x = meas.x;
			subjMeas.y = meas.y;
		}
		protected function onStageResize(e:Event=null, from:IStageAsset=null) : void{
			_displayPosition.width = _stage.stageWidth;
			_displayPosition.height = _stage.stageHeight;
			invalidate();
		}
	}
}