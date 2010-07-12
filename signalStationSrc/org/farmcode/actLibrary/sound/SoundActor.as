package org.farmcode.actLibrary.sound
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.sound.actTypes.*;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.sound.SoundEvent;
	import org.farmcode.sound.SoundManager;
	import org.farmcode.sound.soundControls.ISoundControl;
	
	public class SoundActor extends UniversalActorHelper
	{
		protected var _soundManager:SoundManager = new SoundManager();
		protected var _executionMap:Dictionary = new Dictionary(true);
		
		public function SoundActor(){
			_soundManager.addEventListener(SoundEvent.PLAYBACK_FINISHED,onSoundFinished); 
		}
		protected function onSoundFinished(e:SoundEvent):void{
			var execution:UniversalActExecution = _executionMap[e.soundControl];
			if(execution){
				execution.continueExecution();
				delete _executionMap[e.soundControl];
			}
		}
		
		public var changeTransitionPhases:Array = [SoundPhases.CHANGE_TRANS_SETTINGS];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{changeTransitionPhases}")]
		public function onChangeTransition(cause:ISetTransitionSettingsAct):void{
			_soundManager.fadeDuration = cause.time;
			_soundManager.fadeEasing = cause.easing;
		}
		
		public var changeSettingsIdPhases:Array = [SoundPhases.CHANGE_SETTINGS_ID];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{changeSettingsIdPhases}")]
		public function onChangeSettingsId(cause:IChangeSoundSettingsIdAct):void{
			_soundManager.changeSettingDetails(cause.id, cause.path, cause.storageEnabled, cause.loadFromSettings);
		}
		
		public var changeVolumePhases:Array = [SoundPhases.CHANGE_VOLUME];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{changeVolumePhases}")]
		public function onChangeVolume(cause:IChangeVolumeAct):void{
			_soundManager.globalVolume = cause.volume;
			_soundManager.muted = cause.muted;
		}

		public var addSoundGroupPhases:Array = [SoundPhases.ADD_SOUND_GROUP];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{addSoundGroupPhases}")]
		public function onAddSoundGroup(cause:IAddSoundGroupAct):void{
			_soundManager.addGroupSettings(cause.soundGroup,cause.soundGroupSettings);
		}
		
		public var removeSoundGroupPhases:Array = [SoundPhases.REMOVE_SOUND_GROUP];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{removeSoundGroupPhases}")]
		public function onRemoveSoundGroup(cause:IAddSoundGroupAct):void{
			_soundManager.removeGroupSettings(cause.soundGroup);
		}
		
		public var removeSoundPhases:Array = [SoundPhases.REMOVE_SOUND];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{removeSoundPhases}")]
		public function onRemoveSound(cause:IRemoveSoundAct):void{
			_soundManager.removeSound(cause.soundControl);
		}
		
		public var addSoundPhases:Array = [SoundPhases.ADD_SOUND];
		[ActRule(ActClassRule)]
		[ActReaction(phases="{addSoundPhases}")]
		public function onAddSound(execution:UniversalActExecution, cause:IAddSoundAct):void{
			// TODO: Bug here if sound is discarded immediately by sound manager (e.g. if postpone = false and doesn't play)
			var control:ISoundControl = cause.soundControl;
			if (control == null){
				execution.continueExecution();	
				throw new Error("Cannot play null soundControl");
			}else{
				if(cause.continueAfterCompletion && cause.soundControl.infinite)
				{
					throw new Error("Can't add infinite sound with continueAfterCompletion set to true");
				}
				
				// May throw SoundError here if not added. Should convert to SoundErrorAdvice
				if (_soundManager.playSound(control)){
					if (cause.continueAfterCompletion){
						_executionMap[control] = execution;
					}else{
						execution.continueExecution();	
					}
				}else{
					execution.continueExecution();
				}
			}
		}
	}
}
