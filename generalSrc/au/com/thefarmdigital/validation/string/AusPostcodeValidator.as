package au.com.thefarmdigital.validation.string
{
	/**
	 * Validates an australian postcode. An Australian postcode is defined as any 4 
	 * digit number
	 */
	public class AusPostcodeValidator extends RegExpValidator
	{
		public static const FAILED_ERROR: String = RegExpValidator.FAILED_ERROR;
		
		/**
		 * Creates a new post code validator
		 * 
		 * @param	mandatory	Whether a value is required to be valid
		 */
		public function AusPostcodeValidator(mandatory: Boolean = true, subject:*=null, validationKey:String=null, liveValidation:Boolean=false)
		{
			super(mandatory, /^[0-9]{4}$/, subject, validationKey, liveValidation);
		}		
	}
}