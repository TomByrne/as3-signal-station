package au.com.thefarmdigital.validation.logic
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	/**
	 * Checks a boolean value equals a registered value
	 */
	public class BooleanValidator extends Validator
	{
		public static const FAILED_ERROR: String = CommonValidatorErrors.FAILED;
		
		/** The comparison value for the validate method	*/
		public function get shouldBe():Boolean{
			return _shouldBe;
		}
		public function set shouldBe(value:Boolean):void{
			if(_shouldBe != value){
				_shouldBe = value;
				validateIfLive();
			}
		}
		
		private var _shouldBe:Boolean;
		
		/**
		 * Creates a new boolean validator which tests a value against the given 
		 * value
		 *	
		 * @param	shouldBe	The required value of tested booleans
		 */
		public function BooleanValidator(shouldBe:Boolean=true, subject:*=null, validationKey:String=null, liveValidation:Boolean=false)
		{
			super(subject, validationKey, liveValidation);
			commitLiveChanges = false;
			this.shouldBe = shouldBe;
		}
		
		override protected function _validate(value:*, validationResult:ValidationResult): *
		{
			if ((shouldBe && !value && (!(value is Number) || value!=0)) || (!shouldBe && (value!=false && value!=null && !isNaN(value)))){
				validationResult.errors.push(new ValidatorError(BooleanValidator.FAILED_ERROR));
			}
			return shouldBe;
		}
	}
}