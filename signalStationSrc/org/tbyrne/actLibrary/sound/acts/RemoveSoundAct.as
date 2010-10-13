package org.tbyrne.actLibrary.sound.acts
{
	import org.tbyrne.actLibrary.sound.actTypes.IRemoveSoundAct;
	import org.tbyrne.sound.soundControls.ISoundControl;

	public class RemoveSoundAct extends AbstractSoundControlAct implements IRemoveSoundAct
	{
		public function RemoveSoundAct(soundControl:ISoundControl=null){
			super(soundControl);
		}
	}
}