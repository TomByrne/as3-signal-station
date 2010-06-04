package au.com.thefarmdigital.validation
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * The ValidatorGroup allows a group of IValidator objects to be checked together.
	 * Error messages can be associated with different error types, allowing error
	 * messaging for a collection of controls.
	 */
	public class ValidatorGroup extends EventDispatcher
	{
		public function set liveValidation(value: Boolean): void{
			if (this._liveValidation != value){
				this._liveValidation = value;
				for(var i:* in _validators){
					(i as IValidator).liveValidation = _liveValidation;
				}
				if(value){
					validate();
				}else{
					clearResults();
				}
			}
		}
		public function get liveValidation(): Boolean{
			return this._liveValidation;
		}
		
		protected var _liveValidation:Boolean = false;
		protected var _validators:Dictionary = new Dictionary();
		protected var _validationResult:ValidationResult = new ValidationResult();
		protected var _readableMessages:Dictionary;
		
		public function ValidatorGroup(){
			super();
		}
		public function addValidator(validator:IValidator):void{
			if(!_validators[validator]){
				_validators[validator] = true;
				validator.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onLiveValidatorComplete);
				//validator.addEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, onValidationValueChanged);
				validator.liveValidation = _liveValidation;
			}
		}
		public function removeValidator(validator:IValidator):void{
			if(_validators[validator]){
				delete _validators[validator];
				validator.removeEventListener(ValidationEvent.VALIDATION_COMPLETE, onLiveValidatorComplete);
				//validator.removeEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, onValidationValueChanged);
			}
		}
		public function validate():ValidationResult{
			if(!_liveValidation){
				clearResults();
			}
			var ret:ValidationResult = _validate();
			if(ret.isComplete){
				addErrorMessages(ret);
			}
			return ret;
		}
		protected function _validate():ValidationResult{
			var valid:Boolean = true;
			var invalidControls: Array = new Array();
			var ret:ValidationResult = new ValidationResult();
			_validationResult.isComplete = true;
			_validationResult.errors = [];
			
			for(var i:* in _validators){
				var validator:IValidator = (i as IValidator);
				var result:ValidationResult = (_validators[i] as ValidationResult);
				if(!result){
					result = validator.validate();
					if(result.isComplete){
						_validators[i] = result;
						_validationResult.errors = _validationResult.errors.concat(result.errors);
					}else if(!_liveValidation){
						_validationResult.isComplete = false;
						validator.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onValidationComplete);
					}
				}
			}
			return _validationResult;
		}
		protected function clearResults():void{
			for(var i:* in _validators){
				_validators[i] = true;
			}
		}
		protected function onValidationValueChanged(e:ValidationEvent):void{
			/*if(_liveValidation){
				validate();
			}*/
		}
		protected function onLiveValidatorComplete(e:ValidationEvent):void{
			if(_liveValidation){
				_validators[e.target] = e.validationResult;
				_validate();
				if(_validationResult.isComplete){
					addErrorMessages(_validationResult);
					_validationResult.dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_COMPLETE));
				}
			}
		}
		protected function onValidationComplete(e:ValidationEvent):void{
			e.target.removeEventListener(ValidationEvent.VALIDATION_COMPLETE, onValidationComplete);
			_validators[e.target] = e.validationResult;
			_validate();
			if(_validationResult.isComplete){
				addErrorMessages(_validationResult);
				_validationResult.dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_COMPLETE));
			}
		}
		protected function addErrorMessages(validationResult:ValidationResult):void{
			if(_readableMessages){
				for each(var error:ValidatorError in validationResult.errors){
					if(!error.readableMessage){
						error.readableMessage = _readableMessages[error.errorType];
					}
				}
			}
		}
	}
}