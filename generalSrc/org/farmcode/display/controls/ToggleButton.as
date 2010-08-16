package org.farmcode.display.controls
{
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.states.StateDef;
	import org.farmcode.display.containers.ISelectableRenderer;
	import org.farmcode.display.tabFocus.ITabFocusable;
	import org.farmcode.display.tabFocus.InteractiveAssetFocusWrapper;
	
	public class ToggleButton extends Button implements ISelectableRenderer
	{
		private static var SELECTED_FRAME_LABEL:String = "selected";
		private static var UNSELECTED_FRAME_LABEL:String = "unselected";
		private static var SELECTED_UP_FRAME_LABEL:String = "selectedMouseUp";
		private static var SELECTED_DOWN_FRAME_LABEL:String = "selectedMouseDown";
		private static var SELECTED_OVER_FRAME_LABEL:String = "selectedMouseOver";
		private static var SELECTED_OUT_FRAME_LABEL:String = "selectedMouseOut";
		
		public function get selected():Boolean{
			return _selected;
		}
		public function set selected(value:Boolean):void{
			if(_selected!=value){
				_selected = value;
				_selectedState.selection = (_togglable?(_selected?0:1):-1);
				if(_booleanConsumer && useDataForSelected){
					_booleanConsumer.booleanValue = value;
				}
				if(_selectedChanged)_selectedChanged.perform(this);
			}

		}
		public function get togglable():Boolean{
			return _togglable;
		}
		public function set togglable(value:Boolean):void{
			if(_togglable!=value){
				_togglable = value;
				_selectedState.selection = (_togglable?(_selected?0:1):-1);
			}
		}
		public function get tabFocusable(): ITabFocusable{
			checkIsBound();
			return _tabFocusable;
		}
		
		override public function set data(value:*):void{
			if(super.data!=value){
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.removeHandler(onProviderChanged);
				}
				super.data = value;
				_booleanProvider = (value as IBooleanProvider);
				_booleanConsumer = (value as IBooleanConsumer);
				if(_booleanProvider){
					if(useDataForSelected){
						selected = _booleanProvider.booleanValue;
					}else{
						selected = false;
					}
					_booleanProvider.booleanValueChanged.addHandler(onProviderChanged);
				}else{
					selected = false;
				}
			}else if(!_booleanProvider && _data){
				/*
				If a list's dataProvider array is reset and some items
				in the array are the same we still want to reset their
				selected property.
				*/
				selected = false;
			}
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function get selectedChanged():IAct{
			if(!_selectedChanged)_selectedChanged = new Act();
			return _selectedChanged;
		}
		
		protected var _selectedChanged:Act;
		
		/**
		 * Whether the 'selected property of the data should be used to get/set
		 * the state of the ToggleButton. Only changes behaviour if the data
		 * implements ISelectableData.
		 */
		public var useDataForSelected:Boolean = true;
		
		private var _booleanProvider:IBooleanProvider;
		private var _booleanConsumer:IBooleanConsumer;
		private var _selected:Boolean;
		private var _togglable:Boolean = true;
		private var _tabFocusable:InteractiveAssetFocusWrapper;
		
		protected var _selectedState:StateDef = new StateDef([SELECTED_FRAME_LABEL,UNSELECTED_FRAME_LABEL],1);
		
		public function ToggleButton(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			clicked.addHandler(onClick);
			_tabFocusable = new InteractiveAssetFocusWrapper();
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			_tabFocusable.interactiveAsset = _interactiveArea;
		}
		override protected function unbindFromAsset() : void{
			_tabFocusable.interactiveAsset = null;
			super.unbindFromAsset();
		}
		private function onProviderChanged(from:IBooleanProvider):void{
			if(useDataForSelected)this.selected = from.booleanValue;
		}
		private function onClick(from:Button):void{
			if(_active){
				selected = !selected;
			}
		}
		
		
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_selectedState);
			return fill;
		}
	}
}