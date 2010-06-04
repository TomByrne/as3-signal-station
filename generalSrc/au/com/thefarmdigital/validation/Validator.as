package au.com.thefarmdigital.validation
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	 
	[Event(name="validationComplete",type="au.com.thefarmdigital.validation.ValidationEvent")]
	public class Validator extends EventDispatcher implements IValidator
	{
		/**
		 * @inheritDoc
		 */
		public function get subject():*{
			return _subject;
		}
		public function set subject(value:*):void{
			if(_subject != value){
				if(_validatableSubject && _liveValidation){
					_validatableSubject.removeEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, doLiveValidate);
				}
				_subject = value;
				_validatableSubject = (value as IValidatable);
				if(_validatableSubject && _liveValidation){
					_validatableSubject.addEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, doLiveValidate);
					doLiveValidate();
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get validationKey():String{
			return _validationKey;
		}
		public function set validationKey(value:String):void{
			if(_validationKey != value){
				_validationKey = value;
				validateIfLive();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get liveValidation():Boolean{
			return _liveValidation;
		}
		public function set liveValidation(value:Boolean):void{
			if(_liveValidation != value){
				_liveValidation = value;
				if(_validatableSubject){
					if(value){
						_validatableSubject.addEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, doLiveValidate);
						doLiveValidate();
					}else{
						_validatableSubject.removeEventListener(ValidationEvent.VALIDATION_VALUE_CHANGED, doLiveValidate);
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get commitLiveChanges():Boolean{
			return _commitLiveChanges;
		}
		public function set commitLiveChanges(value:Boolean):void{
			_commitLiveChanges = value;
		}
		
		// override this to avoid new validation beginning before old validation has ended.
		protected function get doCancelPending():Boolean{
			return true;
		}
		
		private var _commitLiveChanges:Boolean = true;
		private var _liveValidation:Boolean;
		private var _validationKey:String;
		private var _subject:*;
		private var _validatableSubject:IValidatable;
		private var _readableMessages:Dictionary;
		private var _isPending:Boolean;
		private var _wasIgnored:Boolean;
		private var _ignoreChanges:Boolean;
		
		protected var _validationResult:ValidationResult;
		
		public function Validator(subject:*=null, validationKey:String=null, liveValidation:Boolean=false):void{
			_validationResult = new ValidationResult();
			_validationResult.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onValidationComplete, false, int.MAX_VALUE);
			this.subject = subject;
			this.validationKey = validationKey;
			this.liveValidation = liveValidation;
		}
		public function addErrorMessage(errorType:String, message:String):void{
			if(!_readableMessages){
				_readableMessages = new Dictionary();
			}
			_readableMessages[errorType] = message;
		}
		public function removeErrorMessage(errorType:String):void{
			if(_readableMessages){
				delete _readableMessages[errorType];
			}
		}
		/**
		 * @inheritDoc
		 */
		public function validate():ValidationResult{
			if(!_isPending || doCancelPending){
				resetResult();
				_validate(getValue(), _validationResult);
				if(_validationResult.isComplete){
					addErrorMessages(_validationResult);
					if(_validatableSubject)_validatableSubject.setValid(_validationResult.isValid,_validationKey);
				}
				return _validationResult;
			}
			_wasIgnored = true;
			return null;
		}
		protected function resetResult():void{
			if(!_validationResult.errors || _validationResult.errors.length)_validationResult.errors = [];
			_validationResult.isComplete = true;
			_validationResult.newValue = null;
		}
		protected function validateIfLive():void{
			if(_validatableSubject && _liveValidation){
				doLiveValidate();
			}
		}
		protected function getValue():*{
			if(_validatableSubject){
				return _validatableSubject.getValidationValue(_validationKey);
			}else if(typeof(_subject)=="object"){
				return _subject[_validationKey];
			}else return _subject;
		}
		protected function doLiveValidate(e:ValidationEvent=null):void{
			if(_ignoreChanges || (e && e.validationKey!=validationKey))return;
			
			if(!_isPending || doCancelPending){
				resetResult();
				
				_validationResult.oldValue = _validatableSubject.getValidationValue(_validationKey);
				if(_validationResult.oldValue){
					_validationResult.newValue = _validate(_validationResult.oldValue, _validationResult);
					if(_validationResult.isComplete){
						onValidationComplete();
					}
				}else{
					_wasIgnored = true;
				}
			}else{
				_wasIgnored = true;
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
		protected function _validate(value:*, validationResult:ValidationResult):*{
			// override me (if asynchronous, set validationResult.isComplete to false and call validationComplete when complete)
		}
		protected function validationComplete():void{
			var event:ValidationEvent = new ValidationEvent(ValidationEvent.VALIDATION_COMPLETE);
			event.validationResult = _validationResult;
			_validationResult.isComplete = true;
			_validationResult.dispatchEvent(event);
		}
		protected function onValidationComplete(e:ValidationEvent=null):void{
			if(e)e.validationResult = _validationResult;
			_validationResult.isComplete = true;
			addErrorMessages(_validationResult);
			if(_validatableSubject && _validationResult.oldValue == getValue()){ // ignore if value has changed since validation began
				if((_validationResult.oldValue!=_validationResult.newValue || _validationResult.oldValue is Object) && _commitLiveChanges){
					_ignoreChanges = true;
					_validatableSubject.setValidationValue(_validationResult.newValue,_validationKey);
					_ignoreChanges = false;
				}
				_validatableSubject.setValid(_validationResult.isValid,_validationKey);
			}
			var event:ValidationEvent = new ValidationEvent(ValidationEvent.VALIDATION_COMPLETE);
			event.validationResult = _validationResult;
			dispatchEvent(event);
			if(_wasIgnored){
				_wasIgnored = false;
				validateIfLive();
			}
		}
	}
}