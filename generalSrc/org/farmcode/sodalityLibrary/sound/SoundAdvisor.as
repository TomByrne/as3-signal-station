package org.farmcode.sodalityLibrary.sound
{
	import org.farmcode.sodality.advice.AsyncMethodAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IAddSoundAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IAddSoundGroupSettingsAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IChangeSoundSettingsIdAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IChangeVolumeAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IRemoveSoundAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IRemoveSoundGroupSettingsAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.ISetSoundSettingsIdAdvice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.ISoundTransitionSettingsAdvice;
	import au.com.thefarmdigital.sound.SoundEvent;
	import au.com.thefarmdigital.sound.SoundManager;
	import au.com.thefarmdigital.sound.soundControls.ISoundControl;
	
	import flash.utils.Dictionary;
	
	[Event(type="org.farmcode.sodalityLibrary.sound.SoundAdvisorEvent", name="volumeChange")]
	public class SoundAdvisor extends DynamicAdvisor
	{
		protected var _soundManager:SoundManager = new SoundManager();
		protected var _adviceMap:Dictionary = new Dictionary(true);
		
		public function SoundAdvisor(){
			_soundManager.addEventListener(SoundEvent.PLAYBACK_FINISHED,onSoundFinished); 
		}
		protected function onSoundFinished(e:SoundEvent):void{
			var advice:AsyncMethodAdvice = _adviceMap[e.soundControl];
			if(advice){
				advice.adviceContinue();
				delete _adviceMap[e.soundControl];
			}
		}
		
		[Trigger(triggerTiming="before")]
		public function onChangeTransition(cause: ISoundTransitionSettingsAdvice):void{
			_soundManager.fadeDuration = cause.time;
			_soundManager.fadeEasing = cause.easing;
		}
		
		[Trigger(triggerTiming="before")]
		public function onChangeSettingsId(cause: IChangeSoundSettingsIdAdvice):void{
			_soundManager.changeSettingDetails(cause.id, cause.path, cause.storageEnabled, cause.loadFromSettings);
		}
		
		[Trigger(triggerTiming="before")]
		public function onChangeVolume(cause: IChangeVolumeAdvice):void{
			_soundManager.globalVolume = cause.volume;
			_soundManager.muted = cause.muted;
		}
		[Trigger(triggerTiming="before")]
		public function onAddSoundGroupSettings(cause: IAddSoundGroupSettingsAdvice):void{
			_soundManager.addGroupSettings(cause.soundGroup,cause.soundGroupSettings);
		}
		[Trigger(triggerTiming="before")]
		public function onRemoveSoundGroupSettings(cause: IRemoveSoundGroupSettingsAdvice):void{
			_soundManager.removeGroupSettings(cause.soundGroup);
		}
		
		[Trigger(triggerTiming="before")]
		public function onRequestRemove(cause: IRemoveSoundAdvice):void{
			_soundManager.removeSound(cause.soundControl);
		}
		[Trigger(triggerTiming="before")]
		public function onSetSettingsId(cause:ISetSoundSettingsIdAdvice):void{
			_soundManager.changeSettingDetails(cause.settingsId,_soundManager.settingsPath,true,true);
		}
		
		[Trigger(triggerTiming="before")]
		public function onRequestPlayback(cause:IAddSoundAdvice, advice:AsyncMethodAdvice, 
			timing: String):void
		{
			// TODO: Bug here if sound is discarded immediately by sound manager (e.g. if postpone = false and doesn't play)
			var control:ISoundControl = cause.soundControl;
			if (control == null){
				advice.adviceContinue();
				throw new Error("Cannot play null soundControl");
			}else{
				if(cause.continueAfterCompletion && cause.soundControl.infinite)
				{
					throw new Error("Can't add infinite sound with continueAfterCompletion set to true");
				}
				
				// May throw SoundError here if not added. Should convert to SoundErrorAdvice
				if (_soundManager.playSound(control)){
					if (cause.continueAfterCompletion){
						_adviceMap[control] = advice;
					}else{
						advice.adviceContinue();	
					}
				}else{
					advice.adviceContinue();
				}
			}
		}
	}
}
