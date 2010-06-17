package org.farmcode.actLibrary.sound.acts
{
	import fl.transitions.easing.None;
	
	import org.farmcode.actLibrary.sound.actTypes.ISetTransitionSettingsAct;
	import org.farmcode.acting.acts.UniversalAct;

	public class SetTransitionSettingsAct extends UniversalAct implements ISetTransitionSettingsAct
	{
		protected var _time: Number;
		protected var _easing: Function;
		
		public function SetTransitionSettingsAct()
		{
			this.time = 0;
			this.easing = None.easeNone;
		}

		[Property(toString="true",clonable="true")]
		public function get easing():Function
		{
			return this._easing;
		}
		public function set easing(easing: Function): void
		{
			this._easing = easing;
		}
		
		[Property(toString="true",clonable="true")]
		public function get time():Number
		{
			return this._time;
		}
		public function set time(time: Number): void
		{
			this._time = time;
		}
	}
}