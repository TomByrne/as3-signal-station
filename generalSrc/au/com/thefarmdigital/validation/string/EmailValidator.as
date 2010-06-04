package au.com.thefarmdigital.validation.string
{
	/**
	 * Checks for valid email addresses
	 */
	public class EmailValidator extends RegExpValidator
	{
		public static const FAILED_ERROR: String = RegExpValidator.FAILED_ERROR;
		
		/**
		 * Creates a new email validator capable of testing valid emails
		 * 
		 * @param	mandatory	Whether the value is required or allowed to be 
		 * 						empty
		 */
		public function EmailValidator(mandatory:Boolean = true, subject:*=null, validationKey:String=null, liveValidation:Boolean=false)
		{
			super(mandatory, /^[A-Z0-9._%+\-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i, subject, validationKey, liveValidation);
		}
	}
}