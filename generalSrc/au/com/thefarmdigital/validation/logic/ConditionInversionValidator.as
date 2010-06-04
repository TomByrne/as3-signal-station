package au.com.thefarmdigital.validation.logic
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.IValidator;
	import au.com.thefarmdigital.validation.ValidationEvent;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	public class ConditionInversionValidator extends Validator
	{
		override public function set subject(value:*):void{
			super.subject = value;
			if(_target){
				_target.subject = value;
			}
		}
		override public function set validationKey(value:String):void{
			super.validationKey = value;
			if(_target){
				_target.validationKey = value;
			}
		}
		public function get target():IValidator{
			return _target;
		}
		public function set target(value:IValidator):void{
			if(_target != value){
				_target = value;
				_target.subject = subject;
				validateIfLive();
			}
		}
		public function get invert():Boolean{
			return _invert;
		}
		public function set invert(value:Boolean):void{
			if(_target != value){
				_invert = value;
				validateIfLive();
			}
		}
		
		private var _target:IValidator;
		private var _invert:Boolean = true;
		private var _nestedResult:ValidationResult;
		private var _listening:Boolean = false;
		
		public function ConditionInversionValidator(target: IValidator = null, invert: Boolean = true, subject:*=null, validationKey:String=null)
		{
			super(subject, validationKey);
			commitLiveChanges = false;
			this.target = target;
			this.invert = invert;
		}

		override protected function _validate(value:*, validationResult:ValidationResult): *{
			if(target){
				_nestedResult = target.validate();
				_validationResult.isComplete = _nestedResult.isComplete;
				_validationResult.errors = [];
				if(_nestedResult.isComplete){
					validationComplete();
				}else if(_listening){
					_listening = true;
					_nestedResult.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onNestedComplete);
				}
			}
			return value;
		}
		protected function onNestedComplete(e:ValidationEvent):void{
			_listening = false;
			_nestedResult.removeEventListener(ValidationEvent.VALIDATION_COMPLETE, onNestedComplete);
			validationComplete();
		}
		override protected function validationComplete():void{
			if (this.invert)
			{
				if(_nestedResult.errors && _nestedResult.errors.length){
					_validationResult.errors = [];
				}else{
					_validationResult.errors = [new ValidatorError(CommonValidatorErrors.FAILED)];
				}
			}
			else if (_nestedResult.errors && _nestedResult.errors.length > 0)
			{
				_validationResult.errors = _nestedResult.errors.slice();
			}
			super.validationComplete();
		}
	}
}