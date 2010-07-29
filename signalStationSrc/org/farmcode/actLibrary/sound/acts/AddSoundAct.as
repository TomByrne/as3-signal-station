package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.core.IRevertableAct;
	import org.farmcode.actLibrary.sound.actTypes.IAddSoundAct;
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.sound.soundControls.ISoundControl;

	public class AddSoundAct extends AbstractSoundControlAct implements IAddSoundAct, IRevertableAct
	{
		protected var _continueAfterCompletion: Boolean = true;
		protected var _added:Boolean = false;
		
		public function AddSoundAct(soundControl:ISoundControl=null, continueAfterCompletion:Boolean=true){
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
		public function get revertAct():IAct{
			return new RemoveSoundAct(soundControl);
		}
		[Property(toString="true",clonable="true")]
		override public function get soundControl(): ISoundControl{
			return super.soundControl;
		}
		override public function set soundControl(value: ISoundControl):void{
			if(super.soundControl !=value){
				if(super.soundControl){
					super.soundControl.soundAdded.removeHandler(onSoundAdded);
					super.soundControl.soundRemoved.removeHandler(onSoundAdded);
				}
				super.soundControl = value;
				if(super.soundControl){
					super.soundControl.soundAdded.addHandler(onSoundAdded);
					super.soundControl.soundRemoved.addHandler(onSoundAdded);
				}
			}
		}
		
		protected function onSoundAdded(from:ISoundControl):void{
			_added = true;
		}
		protected function onSoundRemoved(from:ISoundControl):void{
			_added = false;
		}
	}
}