package au.com.thefarmdigital.validation.logic
{
	import au.com.thefarmdigital.validation.IValidatable;
	import au.com.thefarmdigital.validation.IValidator;
	import au.com.thefarmdigital.validation.ValidationEvent;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;

	public class MultiSubjectValidator extends Validator implements IValidatable
	{
		
		public function get nestedValidator():IValidator{
			return _nestedValidator;
		}
		public function set nestedValidator(value:IValidator):void{
			if(_nestedValidator != value){
				if(_nestedValidator){
					_nestedValidator.removeEventListener(ValidationEvent.VALIDATION_COMPLETE, onNestedComplete);
				}
				_nestedValidator = value;
				if(_nestedValidator){
					_nestedValidator.subject = this;
					_nestedValidator.addEventListener(ValidationEvent.VALIDATION_COMPLETE, onNestedComplete);
				}
				validateIfLive();
			}
		}
		
		private var test:*;
		private var _nestedValidator:IValidator;
		private var _subjectBundles:Array = [];
		
		public function MultiSubjectValidator(nestedValidator:IValidator=null, liveValidation:Boolean=false){
			super(null, null, liveValidation);
			this.nestedValidator = nestedValidator;
		}
		public function addSubject(subject:Object, validationKey:String=null):void{
			_removeSubject(subject, validationKey, false);
			_subjectBundles.push(new SubjectBundle(subject,validationKey));
			validateIfLive();
		}
		protected function removeSubject(subject:Object, validationKey:String=null):void{
			_removeSubject(subject, validationKey, true);
		}
		protected function _removeSubject(subject:Object, validationKey:String, doValidate:Boolean):void{
			var index:int = findBundle(subject, validationKey);
			if(index!=-1){
				_subjectBundles.splice(index,1);
				if(doValidate)validateIfLive();
			}
		}
		protected function findBundle(subject:Object, validationKey:String):int{
			var length:int = _subjectBundles.length;
			for(var i:int=0; i<length; ++i){
				var bundle:SubjectBundle = _subjectBundles[i];
				if(bundle.subject==subject && bundle.validationKey==validationKey){
					return i;
				}
			}
			return -1;
		}
		override protected function getValue():*{
			var value:Array = [];
			for each(var bundle:SubjectBundle in _subjectBundles){
				var cast:IValidatable = (bundle.subject as IValidatable);
				if(cast){
					value.push(cast.getValidationValue(bundle.validationKey));
				}else{
					value.push(bundle.subject[bundle.validationKey]);
				}
			}
			return value;
		}
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var earlyResult:ValidationResult = nestedValidator.validate();
			validationResult.isComplete = earlyResult.isComplete;
			validationResult.newValue = earlyResult.newValue;
			if(validationResult.isComplete)validationResult.errors = validationResult.errors.concat(earlyResult.errors);
			return earlyResult.newValue;
		}
		protected function onNestedComplete(e:ValidationEvent):void{
			var lateResult:ValidationResult = (e.validationResult);
			_validationResult.isComplete = lateResult.isComplete;
			_validationResult.newValue = lateResult.newValue;
			_validationResult.errors = _validationResult.errors.concat(lateResult.errors);
			_validationResult.dispatchEvent(new ValidationEvent(ValidationEvent.VALIDATION_COMPLETE));
		}
		
		// IValidatable implementation
		public function getValidationValue(validityKey:String=null):*{
			return getValue();
		}
		public function setValidationValue(value:*, validityKey:String=null):void{
			// ignore
		}
		public function setValid(valid:Boolean, validityKey:String=null):void{
			for each(var bundle:SubjectBundle in _subjectBundles){
				var cast:IValidatable = (bundle.subject as IValidatable);
				if(cast){
					cast.setValid(valid,bundle.validationKey);
				}
			}
		}
	}
}
class SubjectBundle{
	public var subject:Object;
	public var validationKey:String;
	
	public function SubjectBundle(subject:Object, validationKey:String){
		this.subject = subject;
		this.validationKey = validationKey;
	}
}