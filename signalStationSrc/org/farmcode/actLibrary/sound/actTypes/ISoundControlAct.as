package org.farmcode.actLibrary.sound.actTypes
{
	import org.farmcode.sound.soundControls.ISoundControl;
	
	import org.farmcode.acting.actTypes.IUniversalAct;
	
	public interface ISoundControlAct extends IUniversalAct
	{
		function get soundControl(): ISoundControl;
	}
}