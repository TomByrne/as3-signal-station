package org.farmcode.actLibrary.sound.acts
{
	import org.farmcode.actLibrary.sound.actTypes.IChangeVolumeAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class ChangeVolumeAct extends UniversalAct implements IChangeVolumeAct
	{
		protected var _volume: Number;
		protected var _muted: Boolean;
		
		public function ChangeVolumeAct(volume: Number = 1, muted:Boolean = false)
		{
			super();
			this.volume = volume;
			this.muted = muted;
		}
		
		[Property(toString="true",clonable="true")]
		public function set volume(volume: Number): void{
			this._volume = volume;
		}
		public function get volume(): Number{
			return this._volume;
		}
		
		[Property(toString="true",clonable="true")]
		public function set muted(muted: Boolean): void{
			this._muted = muted;
		}
		public function get muted(): Boolean{
			return this._muted;
		}
	}
}