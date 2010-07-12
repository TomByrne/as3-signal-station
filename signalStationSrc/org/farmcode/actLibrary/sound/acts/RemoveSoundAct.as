package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.sound.actTypes.IRemoveSoundAct;
	import org.farmcode.sound.soundControls.ISoundControl;

	public class RemoveSoundAct extends AbstractSoundControlAct implements IRemoveSoundAct
	{
		public function RemoveSoundAct(soundControl:ISoundControl=null){
			super(soundControl);
		}
	}
}