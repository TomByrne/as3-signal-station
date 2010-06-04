package org.farmcode.sodalityLibrary.control.modifiers
{
	public interface INumberModifier extends IValueModifier
	{
		function inputNumber(value:Number, oldValue:Number):Number;
	}
}