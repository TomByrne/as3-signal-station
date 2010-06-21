package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.sound.actTypes.IAddSoundGroupAct;
	import org.farmcode.acting.acts.UniversalAct;
	import org.farmcode.sound.SoundGroupSettings;

	public class AddSoundGroupAct extends UniversalAct implements IAddSoundGroupAct
	{
		
		[Property(toString="true",clonable="true")]
		public function get soundGroup():String{
			return _soundGroup;
		}
		public function set soundGroup(value:String):void{
			_soundGroup = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get soundGroupSettings():SoundGroupSettings{
			return _soundGroupSettings;
		}
		public function set soundGroupSettings(value:SoundGroupSettings):void{
			_soundGroupSettings = value;
		}
		
		private var _soundGroupSettings:SoundGroupSettings;
		private var _soundGroup:String;
		
		public function AddSoundGroupAct(){
			super();
		}
	}
}