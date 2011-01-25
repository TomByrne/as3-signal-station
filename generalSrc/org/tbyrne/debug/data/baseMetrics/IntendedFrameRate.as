package org.tbyrne.debug.data.baseMetrics
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.binding.PropertyWatcher;
	import org.tbyrne.binding.Watchable;
	import org.tbyrne.debug.data.core.NumberMonitor;
	import org.tbyrne.display.assets.nativeTypes.IStage;
	import org.tbyrne.display.core.IView;
	
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
		
		public function get stage():IStage{
			return _stage;
		}
		public function set stage(value:IStage):void{
			if(_stage!=value){
				_stage = value;
				target = value;
			}
		}
		
		private var _stage:IStage;
		private var _watchable:Watchable;
		
		public function IntendedFrameRate(view:IView=null){
			super(null, "frameRate");
			_watchable = new Watchable([view_name]);
			
			new PropertyWatcher("view.asset.stage",setStage,null,null,this);
			this.view = view;
		}
		protected function setStage(newStage:IStage):void{
			this.stage = newStage;
		}
	}
}