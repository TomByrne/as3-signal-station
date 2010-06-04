package au.com.thefarmdigital.validation
{
	import flash.events.IEventDispatcher;
	
	
	[Event(name="validationValueChanged",type="au.com.thefarmdigital.validation.ValidationEvent")]
	public interface IValidatable extends IEventDispatcher
	{
		function getValidationValue(validityKey:String=null):*;
		function setValidationValue(value:*, validityKey:String=null):void;
		function setValid(valid:Boolean, validityKey:String=null):void;
	}
}