package org.tbyrne.display.controls
{
	import flash.display.DisplayObject;
	
	import org.tbyrne.display.assets.assetTypes.IAsset;
	import org.tbyrne.display.assets.assetTypes.IDisplayAsset;
	import org.tbyrne.display.assets.states.StateDef;
	import org.tbyrne.display.containers.ContainerView;
	import org.tbyrne.display.core.LayoutView;
	import org.tbyrne.validation.validators.IValidator;
	
	public class Control extends ContainerView
	{
		private static var VALID_FRAME_LABEL:String = "valid";
		private static var INVALID_FRAME_LABEL:String = "invalid";
		internal static var ACTIVE_FRAME_LABEL:String = "active";
		internal static var INACTIVE_FRAME_LABEL:String = "inactive";
		
		
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_active!=value){
				_active = value;
				_activeState.selection = (value?0:1);
			}
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
		
		protected var _validator:IValidator;
		protected var _validatorValid:Boolean = true;
		protected var _active:Boolean = true;
		
		protected var _activeState:StateDef = new StateDef([ACTIVE_FRAME_LABEL,INACTIVE_FRAME_LABEL],0);
		protected var _validState:StateDef = new StateDef([VALID_FRAME_LABEL,INVALID_FRAME_LABEL],0);
		
		public function Control(asset:IDisplayAsset=null){
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
	}
}