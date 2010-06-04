package org.farmcode.display.behaviour.controls
{
	
	import au.com.thefarmdigital.validation.ValidationEvent;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.data.dataTypes.IBooleanConsumer;
	import org.farmcode.data.dataTypes.IBooleanProvider;
	import org.farmcode.display.behaviour.containers.ISelectableRenderer;
	import org.farmcode.display.tabFocus.ITabFocusable;
	import org.farmcode.display.tabFocus.InteractiveObjectFocusWrapper;
	
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
				assessLabel();
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
				assessLabel();
			}
		}
		public function get tabFocusable(): ITabFocusable{
			checkIsBound();
			return _tabFocusable;
		}
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			if(_data!=value){
				if(_booleanProvider){
					_booleanProvider.booleanValueChanged.removeHandler(onProviderChanged);
				}
				_data = value;
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
		
		private var _data:*;
		private var _booleanProvider:IBooleanProvider;
		private var _booleanConsumer:IBooleanConsumer;
		private var _selected:Boolean;
		private var _togglable:Boolean = true;
		private var _tabFocusable:ITabFocusable;
		
		public function ToggleButton(asset:DisplayObject=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			asset.addEventListener(MouseEvent.CLICK,onClick);
			var interact:InteractiveObject = (asset as InteractiveObject);
			if(interact){
				interact.mouseEnabled = true;
				_tabFocusable = new InteractiveObjectFocusWrapper(interact);
				var sprite:Sprite = (asset as Sprite);
				if(sprite){
					sprite.mouseChildren = false;
					sprite.buttonMode = true;
				}
			}
			super.bindToAsset();
		}
		override protected function unbindFromAsset() : void{
			super.unbindFromAsset();
			_tabFocusable = null;
			asset.removeEventListener(MouseEvent.CLICK,onClick);
		}
		private function onProviderChanged(from:IBooleanProvider):void{
			if(useDataForSelected)this.selected = from.booleanValue;
		}
		private function onClick(e:Event):void{
			selected = !selected;
			dispatchEventIf(ValidationEvent.VALIDATION_VALUE_CHANGED, ValidationEvent);
		}
		override protected function assessLabel() : void{
			if(_movieClipAsset){
				var labels:Array = [];
				if(selected && _togglable){
					if(_down){
						labels.push(SELECTED_DOWN_FRAME_LABEL);
					}else if(_lastLabel==SELECTED_DOWN_FRAME_LABEL){
						labels.push(SELECTED_UP_FRAME_LABEL);
					}
					if(_over){
						labels.push(SELECTED_OVER_FRAME_LABEL);
					}else if(_lastLabel==SELECTED_OVER_FRAME_LABEL){
						labels.push(SELECTED_OUT_FRAME_LABEL);
					}
					labels.push(SELECTED_FRAME_LABEL);
				}else{
					if(_down){
						labels.push(Button.DOWN_FRAME_LABEL);
					}else if(_lastLabel==Button.DOWN_FRAME_LABEL){
						labels.push(Button.UP_FRAME_LABEL);
					}
					if(_over){
						labels.push(Button.OVER_FRAME_LABEL);
					}else if(_lastLabel==Button.OVER_FRAME_LABEL){
						labels.push(Button.OUT_FRAME_LABEL);
					}
					if(_togglable)labels.push(UNSELECTED_FRAME_LABEL);
				}
				setLabel(labels);
			}
		}
		override public function getValidationValue(validityKey:String=null):*{
			return selected;
		}
	}
}