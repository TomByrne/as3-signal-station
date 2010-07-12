package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.sound.soundControls.ISoundControl;

	public class AddRandomSoundAct extends AddSoundAct
	{
		private var _options: Array;
		private var _targetSound: ISoundControl;
		
		public function AddRandomSoundAct(){
			super(null);
		}
		
		[Property(toString="true",clonable="true")]
		public function get options(): Array{
			return this._options;
		}
		public function set options(value: Array): void{
			this._options = value;
		}
		
		override public function set soundControl(soundControl:ISoundControl):void{
			// ignore
		}
		override public function get soundControl():ISoundControl{
			if(!super.soundControl)chooseRandomOption();
			return super.soundControl;
		}
		
		protected function chooseRandomOption(): void{
			if (this.options == null || this.options.length == 0){
				this.selectOption(null);
			}else{
				var chosenIndex: int = Math.floor(Math.random() * this.options.length);
				this.selectOption(this.options[chosenIndex]);
			}
		}
		
		protected function selectOption(option: *): void{
			if (option == null){
				super.soundControl = null;
			}else{
				super.soundControl = option as ISoundControl;
			}
		}
	}
}