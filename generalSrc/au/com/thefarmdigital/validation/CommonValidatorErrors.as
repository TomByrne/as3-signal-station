package au.com.thefarmdigital.validation
{
	/**
	 * Ensures validator errors match up, e.g. ensures numberValidator's Max error is the same
	 * code as StringValidator's max. Uses high and low numbers so hopefully doesn't intefere with
	 * any custom error numbers. If they do conflict with these standards then no errors
	 * will occur except in the context of a system which relies on a constant value to represent
	 * error types.
	 */
	public class CommonValidatorErrors
	{
		public static const FAILED: String = 			"failed";
		public static const MANDATORY: String = 		"madatory";
		public static const MINIMUM: String = 			"minimum";
		public static const MAXIMUM: String = 			"maximum";
		public static const NAN: String = 				"nan";
		public static const NOT_AN_INTEGER: String = 	"notAnInteger";
	}
}