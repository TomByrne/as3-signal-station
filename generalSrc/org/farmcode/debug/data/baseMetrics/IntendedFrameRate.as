package org.farmcode.debug.data.baseMetrics
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.binding.Watchable;
	import org.farmcode.debug.data.core.NumberMonitor;
	import org.farmcode.display.assets.assetTypes.IStageAsset;
	import org.farmcode.display.core.IView;
	
	public class IntendedFrameRate extends NumberMonitor
	{
		
		private const view_name:String = "view";
		
		/**
		 * @inheritDoc
		 * @handler()
		 */
		public function get viewChanged():IAct{return _watchable.viewChanged;}
		public function get view():IView{return _watchable.view;}
		public function set view(value:IView):void{_watchable.view = value;}
		
		public function get stage():IStageAsset{
			return _stage;
		}
		public function set stage(value:IStageAsset):void{
			if(_stage!=value){
				_stage = value;
				target = value;
			}
		}
		
		private var _stage:IStageAsset;
		private var _watchable:Watchable;
		
		public function IntendedFrameRate(view:IView=null){
			super(null, "frameRate");
			_watchable = new Watchable([view_name]);
			
			new PropertyWatcher("view.asset.stage",setStage,null,null,this);
			this.view = view;
		}
		protected function setStage(newStage:IStageAsset):void{
			this.stage = newStage;
		}
	}
}