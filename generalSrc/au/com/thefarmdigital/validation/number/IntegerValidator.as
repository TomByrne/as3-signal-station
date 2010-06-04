package au.com.thefarmdigital.validation.number
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	/**
	 * An integer validator that checks if the given value is a valid integer 
	 * number within a minimum and maximum value
	 */
	public class IntegerValidator extends NumberValidator
	{
		public static const NOT_AN_INTEGER_ERROR: String = CommonValidatorErrors.NOT_AN_INTEGER;
		
		/**
		 * Creates a new integer validator with the given rules
		 * 
		 * @param	mandatory	Whether a value is required or not
		 * @param	minimum		The minimum value of the number
		 * @param	maximum		The maximum value of the number
		 */
		public function IntegerValidator(mandatory:Boolean=true, 
			minimum:Number=NaN, maximum:Number=NaN)
		{
			super(mandatory, minimum, maximum);
		}
		
		/** The minimum allowed value. minimum is converted to an int value */
		override public function get minimum():Number
		{
			return super.minimum;
		}
		/** @private */
		override public function set minimum(minimum: Number): void{
			if (isNaN(minimum)){
				super.minimum = minimum;
			}else{
				super.minimum = minimum as int;
			}
		}
		
		/** The maximum allowed value. maximum is converted to an int value */
		override public function get maximum():Number
		{
			return super.maximum;
		}
		/** @private */
		override public function set maximum(maximum: Number): void{
			if (isNaN(maximum)){
				super.maximum = maximum;
			}else{
				super.maximum = maximum as int;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			value = super._validate(value, validationResult);
			var round:int = int(value);
			if(round!=value){
				validationResult.errors.push(new ValidatorError(IntegerValidator.NOT_AN_INTEGER_ERROR));
			}
			return round;
		}
	}
}