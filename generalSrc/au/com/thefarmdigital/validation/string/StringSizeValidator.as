package au.com.thefarmdigital.validation.string
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.number.NumberValidator;
	
	
	/**
	 * Validates a string against a set of rules
	 */
	public class StringSizeValidator extends NumberValidator
	{
		public static const MANDATORY_ERROR: String = 	CommonValidatorErrors.MANDATORY;
		public static const MIN_ERROR: String = 		CommonValidatorErrors.MINIMUM;
		public static const MAX_ERROR: String = 		CommonValidatorErrors.MAXIMUM;
		
		/**	White space characters used in validating mandatory values */
		protected static const WHITE_SPACE: Array = [" ", "\n", "\t", "\r"];
		
		/** 
		 * Creates a String validator that checks the presence of a value.
		 * 
		 * @return	A new String Validator
		 */
		public static function createPresentValidator(): StringSizeValidator
		{
			return new StringSizeValidator(true, NaN, 1);
		}
		
		/** 
		 * Creates a String validator that checks the presence of a value which
		 * doesn't consider white space as valid for the mandatory check.
		 * 
		 * @return	A new String Validator
		 */
		public static function createStrictPresentValidator(): StringSizeValidator
		{
			return new StringSizeValidator(true, null, NaN, 1, false);
		}
		
		/** Whether white space is considered when determining mandatory */
		public function get allowWhiteSpaceInMandatory():Boolean{
			return _allowWhiteSpaceInMandatory;
		}
		public function set allowWhiteSpaceInMandatory(value:Boolean):void{
			if(_allowWhiteSpaceInMandatory != value){
				_allowWhiteSpaceInMandatory = value;
				validateIfLive();
			}
		}
		
		private var _mandatory:Boolean;
		private var _allowWhiteSpaceInMandatory:Boolean;
		private var _lastValid:String;
		
		/**
		 * Creates a new string validator for the given rules
		 * 
		 * @param	mandatory	Whether a value is required to be valid
		 * @param	subject		The subject of validation (can be IValidatable)
		 * @param	maximum		The largest allowed length of the string
		 * @param	minimum		The smallest allowed length of the string
		 * @param	allowWhiteSpaceInMandatory	Whether the mandatory will count
		 * 										white space as a valid value
		 */
		public function StringSizeValidator(mandatory:Boolean=true, subject:Object=null, maximum:Number=NaN, minimum:Number=NaN, allowWhiteSpaceInMandatory: Boolean = true){
			super(mandatory, subject, minimum, maximum);
			this.allowWhiteSpaceInMandatory = allowWhiteSpaceInMandatory;
		}
		
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var string:String = (value as String);
			var mandatoryTest: String = string;
			
			if (!this.allowWhiteSpaceInMandatory && mandatoryTest){
				for (var i: uint = 0; i < StringSizeValidator.WHITE_SPACE.length; ++i){
					var wsChar: String = StringSizeValidator.WHITE_SPACE[i] as String;
					mandatoryTest = mandatoryTest.split(wsChar).join("");
				}
			}
			
			super._validate(mandatoryTest?mandatoryTest.length:NaN,validationResult);
			if(!validationResult.errors.length){
				_lastValid = value;
			}
			return _lastValid?_lastValid:value;
		}

	}
}