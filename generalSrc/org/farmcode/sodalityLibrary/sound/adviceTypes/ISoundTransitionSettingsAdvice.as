package org.farmcode.sodalityLibrary.sound.adviceTypes
{
	import org.farmcode.sodalityLibrary.sound.advice.ISoundAdvice;
	
	public interface ISoundTransitionSettingsAdvice extends ISoundAdvice
	{
		function get easing(): Function;
		function get time(): Number;
	}
}