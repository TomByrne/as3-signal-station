package org.tbyrne.sound.soundControls
{
	

	public class CompositeSoundControl extends AbstractSoundControl implements IAccessibleSoundControl
	{
		public function set loops(loops: int): void{
			this._loops = loops;
		}
		public function get loops(): int{
			return this._loops;
		}
		
		private var _loops:int;
		private var _controls: Array;
		
		private var currentSoundIndex: int;
		private var currentLoop: int;
		
		public function CompositeSoundControl(loops: int = 1){
			this.loops = loops;
			this._controls = new Array();
			this.currentLoop = -1;
			this.currentSoundIndex = -1;
		}
		public function get textRepresentation():String{
			var ret:String;
			for each(var soundControl:ISoundControl in _controls){
				var cast:IAccessibleSoundControl = (soundControl as IAccessibleSoundControl);
				if(cast && cast.textRepresentation){
					if(ret)ret += " ";
					else ret = "";
					ret += cast.textRepresentation;
				}
			}
			return ret;
		}
		public function set controls(value: Array): void{
			this._controls = value;
			this.applyVolume();
		}
		public function get controls(): Array{
			return this._controls;
		}
		override public function get infinite():Boolean{
			var inf: Boolean = (loops==0);
			for (var i: uint = 0; i < this.controls.length && !inf; ++i)
			{
				var testControl: ISoundControl = this.controls[i];
				inf = inf && testControl.infinite;
			}
			return inf;
		}
		
		public function addControl(control: ISoundControl): void{
			this._controls.push(control);
			this.applyVolume();
		}
		
		protected function get currentSound(): ISoundControl
		{
			return this.controls[this.currentSoundIndex];
		}
		
		override protected function applyVolume():void{
			if (this.controls != null){
				for (var i: uint = 0; i < this.controls.length; ++i){
					var control: ISoundControl = this.controls[i];
					control.volumeMultiplier = this.volumeMultiplier;
				}
			}
		}

		override public function play():void{
			if (!this.playing){
				this._pending = true;
				if (this.controls.length == 0){
					Log.error( "CompositeSoundControl.play: No sound object to play");
				}else{
					this.currentSoundIndex = 0;
					this.currentLoop = 0;
					this.performBegun();
					this.playCurrentSound();
				}
			}
		}
		
		private function playCurrentSound(): void{
			currentSound.playbackFinished.addHandler(handleCurrentPlaybackFinish);
			currentSound.play();
		}
		
		private function handleCurrentPlaybackFinish(from:ISoundControl): void{
			currentSound.playbackFinished.removeHandler(handleCurrentPlaybackFinish);
			
			if (_pending && ((this.currentSoundIndex + 1) < this.controls.length)){
				this.currentSoundIndex++;
				this.playCurrentSound();
			}else if (_pending && (this.loops == 0 || (this.currentLoop + 1) < this.loops)){
				this.currentLoop++;
				this.currentSoundIndex = 0;
				this.playCurrentSound();
			}else{
				this.finishPlaying();
			}
		}
		
		override public function stop():void{
			if (this.playing){
				_pending = false;
				if (currentSound){
					currentSound.stop();
				}else{
					finishPlaying();
				}
			}
		}
		
		private function finishPlaying(): void{
			this.currentSoundIndex = -1;
			this.currentLoop = -1;
			this.performFinished();
		}
	}
}