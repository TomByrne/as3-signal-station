package au.com.thefarmdigital.validation.number
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	/**
	 * Validates a number against a set of rules
	 */
	public class NumberValidator extends Validator
	{
		public static const MANDATORY_ERROR: String = CommonValidatorErrors.MANDATORY;
		public static const MIN_ERROR: String = CommonValidatorErrors.MINIMUM;
		public static const MAX_ERROR: String = CommonValidatorErrors.MAXIMUM;
		public static const NAN_ERROR: String = CommonValidatorErrors.NAN;
		
		/** Whether the presence of a value is required for validity */
		private var _mandatory:Boolean = true;
		
		/** The maximum allowed value */
		private var _maximum:Number;
		
		/** The minimum allowed value */
		private var _minimum:Number;
		
		/**
		 * Creates a new number validator for the given options
		 * 
		 * @param	mandatory	Whether a value is required or not
		 * @param	subject		The subject of validation (can be IValidatable)
		 * @param	minimum		The minimum value of the number
		 * @param	maximum		The maximum value of the number
		 */
		public function NumberValidator(mandatory:Boolean=true, subject:Object=null, minimum:Number=NaN,
			maximum:Number=NaN)
		{
			this.mandatory = mandatory;
			this.subject = subject;
			this.maximum = maximum;
			this.minimum = minimum;
		}
		
		/** Whether the presence of a value is required for validity */
		public function get mandatory(): Boolean
		{
			return this._mandatory;
		}
		public function set mandatory(value: Boolean): void
		{
			if(value!=_mandatory){
				this._mandatory = value;
				validateIfLive();
			}
		}
		
		/** The minimum value allowed for validity */
		public function get minimum(): Number
		{
			return this._minimum;
		}
		public function set minimum(minimum: Number): void
		{
			if(minimum!=this.minimum){
				this._minimum = minimum;
				validateIfLive();
			}
		}
		
		/** The maximum value allowed for validity */
		public function get maximum(): Number
		{
			return this._maximum;
		}
		public function set maximum(maximum: Number): void
		{
			if(maximum!=this.maximum){
				this._maximum = maximum;
				validateIfLive();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			if(minimum>maximum){
				throw new Error("NumberValidator.getValidationErrors: minimum can't be higher than maximum");
			}
			var errors: Array = new Array();
			if (value is String)
			{
				var str:String = (value as String);
				var test:RegExp = /[0-9.,]*/;
				if (value == "" && mandatory)
				{
					validationResult.errors.push(new ValidatorError(NumberValidator.MANDATORY_ERROR));
				}
				else if (!test.test(str))
				{
					validationResult.errors.push(new ValidatorError(NumberValidator.NAN_ERROR));
				}
				else
				{
					value = parseFloat(str);
				}
			}
			
			var number:Number = (value as Number);
			if(!isNaN(number) || mandatory)
			{
				if(isNaN(number) && mandatory)
				{
					validationResult.errors.push(new ValidatorError(NumberValidator.MANDATORY_ERROR));
				}
				if(!isNaN(maximum) && (number>maximum))
				{
					number = maximum;
					validationResult.errors.push(new ValidatorError(NumberValidator.MAX_ERROR));
				}
				if(!isNaN(minimum) && (number<minimum))
				{
					number = minimum;
					validationResult.errors.push(new ValidatorError(NumberValidator.MIN_ERROR));
				}
			}
			return number;
		}
		
		override public function toString(): String
		{
			return "[NumberValidator mandatory:" + this.mandatory + " min:" + this.minimum + 
				", max:" + this.maximum + "]";
		}
	}
}