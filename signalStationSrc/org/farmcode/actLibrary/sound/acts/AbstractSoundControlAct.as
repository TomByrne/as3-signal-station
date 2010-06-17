package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.sound.actTypes.ISoundControlAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.sound.soundControls.ISoundControl;

	public class AbstractSoundControlAct extends UniversalAct implements ISoundControlAct
	{
		protected var _soundControl:ISoundControl;
		
		public function AbstractSoundControlAct(soundControl:ISoundControl=null){
			super();
			this.soundControl = soundControl;
		}
		
		[Property(toString="true",clonable="true")]
		public function set soundControl(soundControl: ISoundControl): void
		{
			this._soundControl = soundControl;
		}
		public function get soundControl(): ISoundControl
		{
			return this._soundControl;
		}
	}
}