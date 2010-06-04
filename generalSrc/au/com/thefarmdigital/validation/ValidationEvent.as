package au.com.thefarmdigital.validation
{
	import flash.events.Event;

	public class ValidationEvent extends Event
	{
		public static const VALIDATION_VALUE_CHANGED:String = "validationValueChanged";
		public static const VALIDATION_COMPLETE:String = "validationComplete";
		
		public var validationKey:String;
		public var validationResult:ValidationResult;
		
		public function ValidationEvent(type:String, validationKey:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.validationKey = validationKey;
		}
		
	}
}