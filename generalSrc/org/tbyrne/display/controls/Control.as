package org.tbyrne.display.controls
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.data.controls.IControlData;
	import org.tbyrne.data.dataTypes.IBooleanProvider;
	import org.tbyrne.display.DisplayNamespace;
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.containers.ContainerView;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.validation.validators.IValidator;
	
	use namespace DisplayNamespace;
	
	public class Control extends ContainerView
	{
		private static var VALID_FRAME_LABEL:String = "valid";
		private static var INVALID_FRAME_LABEL:String = "invalid";
		DisplayNamespace static var ACTIVE_FRAME_LABEL:String = "active";
		DisplayNamespace static var INACTIVE_FRAME_LABEL:String = "inactive";
		
		
		public function get data():IControlData{
			return _data;
		}
		public function set data(value:IControlData):void{
			if(_data!=value){
				if(_data){
					clearData();
				}
				
				_data = value;
				
				if(_data){
					assessData();
				}
			}
		}		
		
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_activeProvider){
				Log.error("active shouldn't be set when an activeProvider has been supplied (Control.active)");
			}
			setActive(value);
		}
		
		public function get validator():IValidator{
			return _validator;
		}
		public function set validator(value:IValidator):void{
			if(_validator!=value){
				if(_validator){
					_validator.validChanged.removeHandler(onValidChanged);
				}
				_validator = value;
				if(_validator){
					_validator.validChanged.addHandler(onValidChanged);
					_validatorValid = _validator.getValid(false);
				}else{
					_validatorValid = true;
					
				}
				_validState.selection = (_validatorValid?0:1);
			}
		}
		
		protected var _data:IControlData;
		
		protected var _validator:IValidator;
		protected var _validatorValid:Boolean = true;
		protected var _active:Boolean = true;
		protected var _activeProvider:IBooleanProvider;
		
		protected var _activeState:StateDef = new StateDef([ACTIVE_FRAME_LABEL,INACTIVE_FRAME_LABEL],0);
		protected var _validState:StateDef = new StateDef([VALID_FRAME_LABEL,INVALID_FRAME_LABEL],0);
		
		public function Control(asset:IDisplayObject=null){
			super(asset);
		}
		protected function onValidChanged(from:IValidator):void{
			_validatorValid = _validator.getValid(false);
			_validState.selection = (_validatorValid?0:1);
		}
		override protected function fillStateList(fill:Array):Array{
			fill = super.fillStateList(fill);
			fill.push(_activeState);
			fill.push(_validState);
			return fill;
		}
		
		
		
		protected function clearData():void{
			if(_activeProvider){
				_activeProvider.booleanValueChanged.removeHandler(onActiveChanged);
				_activeProvider = null;
			}
		}
		
		protected function assessData():void{
			if(_data.active){
				_activeProvider = _data.active;
				_activeProvider.booleanValueChanged.addHandler(onActiveChanged);
				setActive(_activeProvider.booleanValue);
			}
		}
		
		private function onActiveChanged(from:IBooleanProvider):void{
			setActive(from.booleanValue);
		}		
		
		protected function setActive(value:Boolean):void{
			if(_active!=value){
				_active = value;
				_activeState.selection = (value?0:1);
			}
		}
	}
}