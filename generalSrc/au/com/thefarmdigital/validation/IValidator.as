package au.com.thefarmdigital.validation
{
	import flash.events.IEventDispatcher;
	
	[Event(name="validationComplete",type="au.com.thefarmdigital.validation.ValidationEvent")]
	/**
	 * Tests values to see if they pass the validator's rules
	 */
	public interface IValidator extends IEventDispatcher
	{
		/**
		 * Sets the object upon which to validate. If this object does not implement IValidatable
		 * then live validation will not be available.
		 * 
		 * @see liveValidation
		 */
		function set subject(value:*):void;
		function get subject():*;
		
		/**
		 * A key which can be used to target specific values within a subject. It can behave in two ways:<br><br>
		 * If the <code>subject</code> implements the IValidatable interface then this key will be used
		 * via the <code>getValidationValue</code> and <code>setValidationValue</code> methods.
		 * Most IValidatable objects only provide one validatable value, in these cases this property
		 * should be left <code>null</code>.<br><br>
		 * If the <code>subject</code> dos not implement the IValidatable interface, the validationKey
		 * is treated as a property name on the subject and is mandatory.
		 */
		function set validationKey(value:String):void;
		function get validationKey():String;
		
		/**
		 * Live Validation allows the validator to check the value whenever it changes.<br>
		 * For Example, as a user is typing validation can be executed.<br>
		 * This is only available when the <code>subject</code> property implements the IValidatable
		 * interface.
		 * 
		 * @see subject
		 * @see commitLiveChanges
		 */
		function set liveValidation(value:Boolean):void;
		function get liveValidation():Boolean;
		
		/**
		 * Whether the validator should change the validation value in the subject when live validation is executed.
		 * 
		 * @see liveValidation
		 */
		function set commitLiveChanges(value:Boolean):void;
		function get commitLiveChanges():Boolean;
		
		/**
		 * Checks the validity. If <code>liveValidation</code> is being used this is not neccessary to call.
		 */
		function validate():ValidationResult;
	}
}