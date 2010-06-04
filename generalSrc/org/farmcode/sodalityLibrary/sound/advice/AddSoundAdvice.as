package org.farmcode.sodalityLibrary.sound.advice
{
	import au.com.thefarmdigital.sound.SoundEvent;
	import au.com.thefarmdigital.sound.soundControls.ISoundControl;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IAddSoundAdvice;

	public class AddSoundAdvice extends SoundControlAdvice implements IAddSoundAdvice, IRevertableAdvice
	{
		protected var _continueAfterCompletion: Boolean = true;
		protected var _added:Boolean = false;
		
		public function AddSoundAdvice(soundControl:ISoundControl=null, continueAfterCompletion:Boolean=true){
			super(soundControl);
			this.continueAfterCompletion = continueAfterCompletion;
		}
		
		[Property(toString="true",clonable="true")]
		public function get continueAfterCompletion(): Boolean{
			return this._continueAfterCompletion;
		}
		public function set continueAfterCompletion(value: Boolean): void{
			this._continueAfterCompletion = value;
		}
		
		public function get doRevert(): Boolean{
			return _added;
		}
		public function get revertAdvice():Advice{
			return new RemoveSoundAdvice(soundControl);
		}
		[Property(toString="true",clonable="true")]
		override public function get soundControl(): ISoundControl{
			return super.soundControl;
		}
		override public function set soundControl(value: ISoundControl):void{
			if(super.soundControl !=value){
				if(super.soundControl){
					super.soundControl.removeEventListener(SoundEvent.SOUND_ADDED, onSoundAdded);
					super.soundControl.removeEventListener(SoundEvent.SOUND_REMOVED, onSoundRemoved);
				}
				super.soundControl = value;
				if(super.soundControl){
					super.soundControl.addEventListener(SoundEvent.SOUND_ADDED, onSoundAdded);
					super.soundControl.addEventListener(SoundEvent.SOUND_REMOVED, onSoundRemoved);
				}
			}
		}
		
		protected function onSoundAdded(e:SoundEvent):void{
			_added = true;
		}
		protected function onSoundRemoved(e:SoundEvent):void{
			_added = false;
		}
	}
}