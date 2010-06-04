package org.farmcode.sodalityLibrary.control.adviceTypes
{
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.control.IControlScheme;

	public interface IChangeControlAdvice extends IAdvice
	{
		function set oldControlScheme(value:IControlScheme):void;
		function get controlScheme():IControlScheme;
	}
}