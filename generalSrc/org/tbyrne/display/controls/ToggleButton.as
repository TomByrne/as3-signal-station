package org.tbyrne.display.controls
{
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	import org.tbyrne.data.dataTypes.IBooleanConsumer;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.containers.ISelectableRenderer;
	import org.tbyrne.display.tabFocus.ITabFocusable;
	import org.tbyrne.display.tabFocus.InteractiveAssetFocusWrapper;
	
	use namespace DisplayNamespace;
	
	public class ToggleButton extends Button implements ISelectableRenderer
	{
		DisplayNamespace static var STATE_SELECTED:String = "selected";
		DisplayNamespace static var STATE_UNSELECTED:String = "unselected";
		
		public function get selected():Boolean{
			return _selected;
		}
		public function set selected(value:Boolean):void{
			if(_booleanConsumer && useDataForSelected){
				_ignoreDataChanges = true;
				_booleanConsumer.booleanValue = value;
				value = _booleanProvider.booleanValue;
				_ignoreDataChanges = false;
			}
			if(_selected!=value){
				_selected = value;
				_selectedState.selection = (_togglable?(_selected?0:1):-1);
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
			if(!_tabFocusable)_tabFocusable = new InteractiveAssetFocusWrapper(_interactiveObjectAsset);
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
		private var _ignoreDataChanges:Boolean;
		
		protected var _selectedState:StateDef = new StateDef([STATE_SELECTED,STATE_UNSELECTED],1);
		
		public function ToggleButton(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function init() : void{
			super.init();
			clicked.addHandler(onClick);
		}
		override protected function bindToAsset() : void{
			super.bindToAsset();
			if(_tabFocusable){
				_tabFocusable.interactiveAsset = _interactiveArea;
			}
		}
		override protected function unbindFromAsset() : void{
			if(_tabFocusable){
				_tabFocusable.interactiveAsset = null;
			}
			super.unbindFromAsset();
		}
		private function onProviderChanged(from:IBooleanProvider):void{
			if(useDataForSelected && !_ignoreDataChanges)this.selected = from.booleanValue;
		}
		private function onClick(from:Button):void{
			if(_active){
				selected = !selected;
			}
		}
		
		
		override protected function fillStateList(fill:Array):Array{
			fill.push(_selectedState);
			fill = super.fillStateList(fill);
			return fill;
		}
	}
}