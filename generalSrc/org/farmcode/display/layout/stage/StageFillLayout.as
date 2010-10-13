package org.farmcode.display.layout.stage
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractSeperateLayout;
	import org.farmcode.display.layout.ILayoutSubject;

	public class StageFillLayout extends AbstractSeperateLayout
	{
		public function get stage():IStageAsset{
			return _stage;
		}
		
		private var _stage:IStageAsset;
		
		public function StageFillLayout(scopeView:IView=null){
			super(scopeView);
			new PropertyWatcher("scopeView.asset.stage",setStage,null,unsetStage,this);
		}
		protected function unsetStage(oldStage:IStageAsset):void{
			oldStage.resize.removeHandler(onStageResize);
			_stage = null;
		}
		protected function setStage(stage:IStageAsset):void{
			_stage = stage;
			stage.resize.addHandler(onStageResize);
			onStageResize(null,stage);
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
			_size.x = from.stageWidth;
			_size.y = from.stageHeight;
			invalidateSize();
		}
	}
}