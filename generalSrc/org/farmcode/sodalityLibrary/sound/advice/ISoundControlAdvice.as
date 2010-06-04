package org.farmcode.sodalityLibrary.sound.advice
{
	import au.com.thefarmdigital.sound.soundControls.ISoundControl;
	
	public interface ISoundControlAdvice extends ISoundAdvice
	{
		function get soundControl(): ISoundControl;
	}
}