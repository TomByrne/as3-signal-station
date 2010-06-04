package au.com.thefarmdigital.sound.soundControls
{
	import org.farmcode.core.DelayedCall;
	
	public class SilentSoundControl extends AbstractSoundControl
	{
		private var _time: Number;
		private var _doneCall: DelayedCall;
		
		public function SilentSoundControl(time: Number = 0){
			this.time = time;
		}
		
		protected function set doneCall(value: DelayedCall): void{
			if (this.doneCall){
				this.doneCall.clear();
			}
			this._doneCall = value;
		}
		protected function get doneCall(): DelayedCall{
			return this._doneCall;
		}
		
		public function set time(value: Number): void{
			this._time = value;
		}
		public function get time(): Number{
			return this._time;
		}
		override public function get infinite(): Boolean{
			return this._time==0;
		}
		
		override public function play(): void{
			if (!this._pending){
				this._pending = true;
				
				if (this.infinite){
					this.doneCall = null;
				}else{
					this.doneCall = new DelayedCall(this.stop, this.time);
					this.doneCall.begin();
				}
			}
		}
		
		override public function stop():void{
			this._pending = false;
			this.doneCall = null;
			this.dispatchFinished();
		}
	}
}