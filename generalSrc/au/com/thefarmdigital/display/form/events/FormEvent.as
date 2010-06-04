package au.com.thefarmdigital.display.form.events
{
	import au.com.thefarmdigital.validation.ValidationResult;
	
	import flash.events.Event;

	public class FormEvent extends Event
	{
		public static const SUBMIT:String = "submit";
		public static const CLEAR:String = "clear";
		public static const INVALID:String = "invalid";
		public static const FEEDBACK_CHANGE:String = "feedbackChange";
		
		public var validationResult:ValidationResult;
		
		public function FormEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event{
			return new FormEvent(this.type, this.bubbles, this.cancelable);
		}
	}
}