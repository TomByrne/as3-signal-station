package au.com.thefarmdigital.validation.string
{
	/**
	 * Validates australian mobile and land line numbers of the formats:
	 * 
	 *   02########
	 *   03########
	 *   04########
	 *   07########
	 *   08########
	 */
	public class AusPhoneNumberValidator extends RegExpValidator
	{
		public static const FAILED_ERROR: String = RegExpValidator.FAILED_ERROR;
		
		/**
		 * Creates a new australian phone number validator
		 * 
		 * @param	mandatory	Whether a value is required to be valid
		 */
		public function AusPhoneNumberValidator(mandatory: Boolean = true, subject:*=null, validationKey:String=null, liveValidation:Boolean=false)
		{
			super(mandatory, /^0[23478]{1}[0-9]{8}$/i, subject, validationKey, liveValidation);
		}
	}
}