package au.com.thefarmdigital.validation.string
{
	import au.com.thefarmdigital.validation.CommonValidatorErrors;
	import au.com.thefarmdigital.validation.ValidationResult;
	import au.com.thefarmdigital.validation.Validator;
	import au.com.thefarmdigital.validation.ValidatorError;
	
	
	/**
	 * Evaluates regular expressions to test a value's validity
	 */
	public class RegExpValidator extends Validator
	{
		public static const FAILED_ERROR: String = CommonValidatorErrors.FAILED;
		
		private var _mandatory: Boolean;
		private var _expression: RegExp;
		private var _lastValid:String;
		
		/**
		 * Creates a new regex validator for the given configurations
		 * 
		 * @param	mandatory	Whether the value is required or allowed to be null
		 * @param	expressionSource	The regular expression to evaluate
		 */
		public function RegExpValidator(mandatory: Boolean = true, expression: RegExp = null, subject:*=null, validationKey:String=null, liveValidation:Boolean=false){
			super(subject, validationKey, liveValidation);
			
			this.mandatory = mandatory;
			this.expression = expression;
		}
		
		/** Whether the presence of a value is required to pass validation */
		public function get mandatory(): Boolean{
			return this._mandatory;
		}
		/** @private */
		public function set mandatory(mandatory: Boolean): void{
			if(_mandatory != mandatory){
				this._mandatory = mandatory;
				validateIfLive();
			}
		}
		
		/** The expression used to check validity. The value must conform to this 
		    expression */
		public function get expression(): RegExp{
			return this._expression;
		}
		/** @private */
		public function set expression(expression: RegExp): void{
			if(_expression != expression){
				this._expression = expression;
				validateIfLive();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function _validate(value:*, validationResult:ValidationResult):*{
			var strValue: String = (value as String);
			
			var errors: Array = new Array();
			if ((mandatory || (strValue != null && strValue != "")) && !this._expression.test(strValue)){
				validationResult.errors.push(new ValidatorError(RegExpValidator.FAILED_ERROR));
			}else{
				_lastValid = value;
			}
			return _lastValid?_lastValid:value;
		}
	}
}