package org.tbyrne.validation.validators
{
	import org.tbyrne.acting.actTypes.IAct;

	public interface IValidator
	{
		/**
		 * handler(from:IValidator)
		 */
		function get validChanged():IAct;
		function get errorDetails():Array;
		/**
		 * Whether the validChanged act should be triggered
		 * when this validator becomes invalid (it will still
		 * be fired the next time the getValid(true) is called).
		 */
		function set lazyInvalidation(value:Boolean):void;
		function get lazyInvalidation():Boolean;
		
		/**
		 * @param forceCheck If lazyInvalidation is true, then this 
		 * variable determines whether validity should be checked
		 * (and lazyInvalidation called).
		 */
		function getValid(forceCheck:Boolean):Boolean;
	}
}