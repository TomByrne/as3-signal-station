package org.farmcode.sodalityLibrary.sound.adviceTypes
{
	import org.farmcode.sodalityLibrary.sound.advice.ISoundAdvice;
	
	public interface IChangeVolumeAdvice extends ISoundAdvice
	{
		function get volume(): Number;
		function get muted(): Boolean;
	}
}