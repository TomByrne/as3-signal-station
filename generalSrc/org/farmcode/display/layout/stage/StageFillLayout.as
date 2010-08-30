package org.farmcode.display.layout.stage
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.farmcode.display.assets.assetTypes.IDisplayAsset;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.AbstractSeperateLayout;
	import org.farmcode.display.layout.ILayoutSubject;

	public class StageFillLayout extends AbstractSeperateLayout
	{
		public function get stage():IStageAsset{
			return _stage;
		}
		override public function set scopeView(value:IView):void{
			if(scopeView != value){
				if(scopeView){
					scopeView.assetChanged.removeHandler(onAssetChanged);
				}
				super.scopeView = value;
				if(value){
					scopeView.assetChanged.addHandler(onAssetChanged);
					setAsset(value.asset);
				}else setAsset(null);
			}
		}
		
		private var _asset:IDisplayAsset;
		private var _stage:IStageAsset;
		private var _stageSize:Rectangle = new Rectangle();
		
		public function StageFillLayout(scopeView:IView=null){
			super(scopeView);
		}
		protected function onAssetChanged(from:IView) : void{
			setAsset(scopeView.asset);
		}
		protected function setAsset(asset:IDisplayAsset) : void{
			if(_asset!=asset){
				if(_asset){
					_asset.addedToStage.removeHandler(onAddedToStage);
					_asset.removedFromStage.removeHandler(onRemovedFromStage);
				}
				_asset = asset;
				if(_asset){
					_asset.addedToStage.addHandler(onAddedToStage);
					_asset.removedFromStage.addHandler(onRemovedFromStage);
					setStage(_asset.stage);
				}else{
					setStage(null);
				}
			}
		}
		protected function onAddedToStage(from:IDisplayAsset) : void{
			setStage(from.stage);
		}
		protected function onRemovedFromStage(from:IDisplayAsset) : void{
			setStage(null);
		}
		protected function setStage(value:IStageAsset):void{
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