package org.farmcode.display.controls.toolTip
{
	import org.farmcode.display.controls.Control;
	import org.farmcode.validation.validators.IValidator;

	public class ControlValidTrigger extends AbstractToolTipTrigger
	{
		override public function get data():*{
			return _control && _control.validator?_control.validator.errorDetails:null;
		}
		public function get control():Control{
			return _control;
		}
		public function set control(value:Control):void{
			if(_control!=value){
				_control = value;
				setAnchorView(_control);
				checkValid();
				if(_control)_control.validator = _validator;
			}
		}
		
		override public function get tipType():String{
			return ToolTipTypes.DATA_ENTRY_ERROR;
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
				if(_control)_control.validator = _validator;
			}
		}
		
		private var _validator:IValidator;
		private var _validatorValid:Boolean;
		private var _control:Control;
		
		public function ControlValidTrigger(){
			super();
		}
		protected function onValidChanged(from:IValidator):void{
			_validatorValid = _validator.getValid(false);
			checkValid();
		}
		protected function checkValid():void{
			if(_validator && !_validatorValid){
				setActive(true);
			}else{
				setActive(false);
			}
		}
	}
}