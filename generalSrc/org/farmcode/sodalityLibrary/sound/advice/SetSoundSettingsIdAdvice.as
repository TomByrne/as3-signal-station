package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.ISetSoundSettingsIdAdvice;

	public class SetSoundSettingsIdAdvice extends Advice implements ISetSoundSettingsIdAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get settingsId():String{
			return _settingsId;
		}
		public function set settingsId(value:String):void{
			_settingsId = value;
		}
		
		private var _settingsId:String;
		
		public function SetSoundSettingsIdAdvice(settingsId:String=null){
			super();
			this.settingsId = settingsId;
		}
	}
}