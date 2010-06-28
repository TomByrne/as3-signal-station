package org.farmcode.display.controls.toolTip
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.core.ILayoutView;
	
	public class ProxyToolTipTrigger implements IToolTipTrigger
	{
		public function get toolTipTrigger():IToolTipTrigger{
			return _toolTipTrigger;
		}
		public function set toolTipTrigger(value:IToolTipTrigger):void{
			if(_toolTipTrigger!=value){
				if(_toolTipTrigger){
					_toolTipTrigger.activeChanged.removeHandler(onActiveChanged);
					_toolTipTrigger.dataAnchorChanged.removeHandler(onDataAnchorChanged);
					_toolTipTrigger.annotationKey = null;
				}
				_toolTipTrigger = value;
				if(_toolTipTrigger){
					_toolTipTrigger.activeChanged.addHandler(onActiveChanged);
					_toolTipTrigger.dataAnchorChanged.addHandler(onDataAnchorChanged);
					_toolTipTrigger.annotationKey = _annotationKey;
				}
				if(_activeChanged)_activeChanged.perform(this);
				if(_dataAnchorChanged)_dataAnchorChanged.perform(this);
			}
		}
		public function get tipType():String{
			return _toolTipTrigger?_toolTipTrigger.tipType:null
		}
		
		/**
		 * @inheritDoc
		 */
		public function get activeChanged():IAct{
			if(!_activeChanged)_activeChanged = new Act();
			return _activeChanged;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get dataAnchorChanged():IAct{
			if(!_dataAnchorChanged)_dataAnchorChanged = new Act();
			return _dataAnchorChanged;
		}
		
		protected var _dataAnchorChanged:Act;
		protected var _activeChanged:Act;
		private var _toolTipTrigger:IToolTipTrigger;
		private var _annotationKey:*;
		
		public function ProxyToolTipTrigger(){
		}
		public function onActiveChanged(from:IToolTipTrigger):void{
			if(_activeChanged)_activeChanged.perform(this);
		}
		public function onDataAnchorChanged(from:IToolTipTrigger):void{
			if(_dataAnchorChanged)_dataAnchorChanged.perform(this);
		}
		
		public function set annotationKey(value:*):void{
			_annotationKey = value;
			if(_toolTipTrigger){
				_toolTipTrigger.annotationKey = _annotationKey;
			}
		}
		public function get active():Boolean{
			return _toolTipTrigger?_toolTipTrigger.active:false;
		}
		public function get anchorView():ILayoutView{
			return _toolTipTrigger?_toolTipTrigger.anchorView:null;
		}
		public function get anchor():String{
			return _toolTipTrigger?_toolTipTrigger.anchor:null;
		}
		public function get data():*{
			return _toolTipTrigger?_toolTipTrigger.data:null;
		}
	}
}