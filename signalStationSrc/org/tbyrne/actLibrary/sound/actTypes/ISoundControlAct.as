package org.tbyrne.actLibrary.sound.actTypes
{
	import org.tbyrne.sound.soundControls.ISoundControl;
	
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public interface ISoundControlAct extends IUniversalAct
	{
		function get soundControl(): ISoundControl;
	}
}