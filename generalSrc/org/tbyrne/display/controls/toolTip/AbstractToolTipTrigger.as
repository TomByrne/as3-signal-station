package org.tbyrne.display.controls.toolTip
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.display.constants.Anchor;
	import org.tbyrne.display.core.ILayoutView;
	
	public class AbstractToolTipTrigger implements IToolTipTrigger
	{
		public function get data():*{
			return null;
		}
		
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor != value){
				_anchor = value;
				if(_dataAnchorChanged)_dataAnchorChanged.perform(this);
			}
		}
		
		public function get annotationKey():*{
			return _annotationKey;
		}
		public function set annotationKey(value:*):void{
			if(_annotationKey!=value){
				_annotationKey = value;
				if(_annotationKeyChanged)_annotationKeyChanged.perform(this);
			}
		}
		
		public function get tipType():String{
			return null;
		}
		
		public function get anchorView():ILayoutView{
			return _anchorView;
		}
		public function get active():Boolean{
			return _active;
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
		
		/**
		 * handler(from:AbstractToolTipTrigger)
		 */
		public function get annotationKeyChanged():IAct{
			if(!_annotationKeyChanged)_annotationKeyChanged = new Act();
			return _annotationKeyChanged;
		}
		
		protected var _annotationKeyChanged:Act;
		protected var _dataAnchorChanged:Act;
		protected var _activeChanged:Act;
		
		protected var _annotationKey:*;
		protected var _active:Boolean;
		protected var _anchorView:ILayoutView;
		protected var _anchor:String = Anchor.RIGHT;
		protected var _data:*;
		
		public function AbstractToolTipTrigger(){
		}
		
		protected function unbindAnchorView(view:ILayoutView):void{
		}
		protected function bindAnchorView(view:ILayoutView):void{
		}
		protected function setActive(value:Boolean):void{
			if(_active!=value){
				_active = value;
				if(_activeChanged)_activeChanged.perform(this);
			}
		}
		protected function setAnchorView(value:ILayoutView):void{
			if(_anchorView!=value){
				if(_anchorView)unbindAnchorView(_anchorView);
				_anchorView = value;
				if(_anchorView)bindAnchorView(_anchorView);
				if(_dataAnchorChanged)_dataAnchorChanged.perform(this);
			}
		}
	}
}