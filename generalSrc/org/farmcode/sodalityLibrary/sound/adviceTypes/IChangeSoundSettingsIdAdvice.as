package org.farmcode.sodalityLibrary.sound.adviceTypes
{
	import org.farmcode.sodalityLibrary.sound.advice.ISoundAdvice;
	
	public interface IChangeSoundSettingsIdAdvice extends ISoundAdvice
	{
		function get id(): String;
		function get path(): String;
		function get loadFromSettings(): Boolean;
		function get storageEnabled(): Boolean;
	}
}