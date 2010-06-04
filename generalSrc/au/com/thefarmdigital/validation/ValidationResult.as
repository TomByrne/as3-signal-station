package au.com.thefarmdigital.validation
{
	import flash.events.EventDispatcher;
	
	[Event(name="validationComplete",type="au.com.thefarmdigital.validation.ValidationEvent")]
	public class ValidationResult extends EventDispatcher
	{
		public var isComplete:Boolean;
		public var errors:Array;
		public var oldValue:*;// value when validation begun
		public var newValue:*;// value recalculated by validation
		
		public function get isValid():Boolean{
			return (!errors || !errors.length);
		}
	}
}