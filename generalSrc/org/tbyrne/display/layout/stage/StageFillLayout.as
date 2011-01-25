package org.tbyrne.display.layout.stage
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.tbyrne.binding.PropertyWatcher;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.core.IView;
	import org.tbyrne.display.layout.AbstractSeperateLayout;
	import org.tbyrne.display.layout.ILayoutSubject;

	public class StageFillLayout extends AbstractSeperateLayout
	{
		public function get stage():IStage{
			return _stage;
		}
		
		private var _stage:IStage;
		
		public function StageFillLayout(scopeView:IView=null){
			super(scopeView);
			new PropertyWatcher("scopeView.asset.stage",setStage,null,unsetStage,this);
		}
		protected function unsetStage(oldStage:IStage):void{
			oldStage.resize.removeHandler(onStageResize);
			_stage = null;
		}
		protected function setStage(stage:IStage):void{
			_stage = stage;
			stage.resize.addHandler(onStageResize);
			onStageResize(stage);
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
		protected function onStageResize(from:IStage=null) : void{
			_size.x = from.stageWidth;
			_size.y = from.stageHeight;
			invalidateSize();
		}
	}
}