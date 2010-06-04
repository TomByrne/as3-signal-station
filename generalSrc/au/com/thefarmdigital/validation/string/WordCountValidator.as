package au.com.thefarmdigital.validation.string
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.number.NumberValidator;
	
	/**
	 * Validates a string against a set of rules
	 */
	public class WordCountValidator extends NumberValidator
	{
		public static const MANDATORY_ERROR: String = 	CommonValidatorErrors.MANDATORY;
		public static const MIN_ERROR: String =		 	CommonValidatorErrors.MINIMUM;
		public static const MAX_ERROR: String =			CommonValidatorErrors.MAXIMUM;	
		
		/**
		 * Creates a new number validator for the given options
		 * 
		 * @param	mandatory	Whether a value is required or not
		 * @param	minimum		The minimum value of the number
		 * @param	maximum		The maximum value of the number
		 */		
		public function WordCountValidator(mandatory:Boolean=true, minimum:Number=NaN,
			maximum:Number=NaN){
			super(mandatory,minimum,maximum);
		}
		
		private var _lastValid:String;
		
		/**
		 * @inheritDoc
		 */
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var string:String = value;
			var wordCount:int = 0;
			if(string && string.length){
				wordCount = string.split(/[,. ?!:;]+/).length;
			}
			
			super._validate(wordCount,validationResult);
			
			if(!validationResult.errors.length && string){
				_lastValid = string;
			}
			
			return _lastValid?_lastValid:string;
		}
		
		override public function toString(): String
		{
			return "[WordCountValidator mandatory:" + this.mandatory + " min:" + this.minimum + 
				", max:" + this.maximum + "]";
		}		
	}
}