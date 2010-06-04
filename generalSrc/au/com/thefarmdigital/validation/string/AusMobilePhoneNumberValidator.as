package au.com.thefarmdigital.validation.string
{
	/**
	 * Validates australian mobile phone numbers. The format allowed is: 04########
	 */
	public class AusMobilePhoneNumberValidator extends RegExpValidator
	{
		public static const FAILED_ERROR: String = RegExpValidator.FAILED_ERROR;
		
		/**
		 * Creates a new mobile phone number validator
		 * 
		 * @param	mandatory	Whether a value is required to be valid
		 */
		public function AusMobilePhoneNumberValidator(mandatory: Boolean = true, subject:*=null, validationKey:String=null, liveValidation:Boolean=false)
		{
			super(mandatory, /^04[0-9]{8}$/i, subject, validationKey, liveValidation);
		}
	}
}