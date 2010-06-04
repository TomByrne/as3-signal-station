package au.com.thefarmdigital.display.form
{
	import au.com.thefarmdigital.display.controls.Control;
	import au.com.thefarmdigital.validation.IValidator;
	import au.com.thefarmdigital.validation.ValidationResult;
	
	import flash.display.InteractiveObject;
	import flash.events.IEventDispatcher;
	
	[Event(name="submit",	type="au.com.thefarmdigital.display.form.events.FormEvent")]
	[Event(name="clear",	type="au.com.thefarmdigital.display.form.events.FormEvent")]
	[Event(name="invalid",	type="au.com.thefarmdigital.display.form.events.FormEvent")]
	public interface IForm extends IEventDispatcher
	{
		function addControl(control: Control, validator:IValidator=null): void;
		function addSubmitButton(button: InteractiveObject): void;
		function addClearButton(button: InteractiveObject): void;
		function addButton(button:InteractiveObject, type:String = null):void;
		function removeControl(control:Control):void;
		
		function validate():ValidationResult;
		
		function set enabled(enabled: Boolean): void;
		function get enabled(): Boolean;
		
		function set visible(visible: Boolean): void;
		function get visible(): Boolean;
		
		function clear():void;
	}
}