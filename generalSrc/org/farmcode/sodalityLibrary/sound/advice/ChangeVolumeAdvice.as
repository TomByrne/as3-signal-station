package org.farmcode.sodalityLibrary.sound.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.sound.adviceTypes.IChangeVolumeAdvice;

	public class ChangeVolumeAdvice extends Advice implements IChangeVolumeAdvice
	{
		protected var _volume: Number;
		protected var _muted: Boolean;
		
		public function ChangeVolumeAdvice(volume: Number = 1, muted:Boolean = false)
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