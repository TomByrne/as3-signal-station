package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.sound.soundControls.SoundTransformControl;

	public class AddSoundTransformAct extends AddSoundAct
	{
		public function get transformSubject():Object{
			return soundTransform?soundTransform.subject:null;
		}
		public function set transformSubject(value:Object):void{
			if(transformSubject!=value){
				_subject = value;
				soundTransform = null; // so that each SoundTransform gets it's own ISoundControl
				checkControl();
			}
		}
		public function get transformProperty():String{
			return soundTransform?soundTransform.transformProperty:null;
		}
		public function set transformProperty(value:String):void{
			if(transformProperty!=value){
				_transformProperty = value;
				checkControl();
			}
		}
		
		private var _subject:Object;
		private var _transformProperty:String;
		private var soundTransform:SoundTransformControl;
		
		public function AddSoundTransformAct(transformSubject:Object=null, transformProperty:String="soundTransform"){
			super();
			this.transformSubject = transformSubject;
			this.transformProperty = transformProperty;
			this.continueAfterCompletion = false;
		}
		protected function checkControl():void{
			if(!soundTransform){
				soundControl = soundTransform = new SoundTransformControl(transformSubject, transformProperty);
				soundTransform.subject = _subject;
				soundTransform.transformProperty = _transformProperty;
			}
		}
	}
}