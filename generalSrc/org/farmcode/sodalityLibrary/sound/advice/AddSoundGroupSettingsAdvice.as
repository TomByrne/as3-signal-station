package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IAddSoundGroupSettingsAdvice;
	import au.com.thefarmdigital.sound.SoundGroupSettings;

	public class AddSoundGroupSettingsAdvice extends Advice implements IAddSoundGroupSettingsAdvice
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
		
		public function AddSoundGroupSettingsAdvice(){
			super();
		}
	}
}