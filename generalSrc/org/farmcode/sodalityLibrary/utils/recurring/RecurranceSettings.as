package org.farmcode.sodalityLibrary.utils.recurring
{
	public class RecurranceSettings
	{
		private var _minInterval: Number;
		private var _maxInterval: Number;
		private var _executeOnStart: Boolean;
		private var _useSeconds: Boolean;

		public function RecurranceSettings(minInterval: Number = NaN, maxInterval: Number = NaN, 
			executeOnStart: Boolean = false, useSeconds: Boolean = true)
		{
			this.minInterval = minInterval;
			this.maxInterval = maxInterval;
			this.executeOnStart = executeOnStart;
			this.useSeconds = useSeconds;
		}
		
		[Property(toString="true", clonable="true")]
		public function get useSeconds(): Boolean
		{
			return this._useSeconds;
		}
		public function set useSeconds(value: Boolean): void
		{
			this._useSeconds = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get executeOnStart(): Boolean
		{
			return this._executeOnStart;
		}
		public function set executeOnStart(value: Boolean): void
		{
			this._executeOnStart = value;
		}
		
		public function get interval(): Number
		{
			var interval: Number = NaN;
			if (this.minInterval == this.maxInterval)
			{
				interval = this.minInterval;
			}
			return interval;
		}
		public function set interval(value: Number): void
		{
			this.minInterval = value;
			this.maxInterval = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get minInterval(): Number
		{
			return this._minInterval;
		}
		public function set minInterval(value: Number): void
		{
			this._minInterval = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get maxInterval(): Number
		{
			return this._maxInterval;
		}
		public function set maxInterval(value: Number): void
		{
			this._maxInterval = value;
		}
		
		public function joinOn(baseSettings: RecurranceSettings): RecurranceSettings
		{
			var newSettings: RecurranceSettings = null;
			if (baseSettings.useSeconds != this.useSeconds)
			{
				throw new Error("Cannot join seconds based setting to frame based setting");
			}
			else
			{			
				newSettings = baseSettings.clone();
				if (!isNaN(this.minInterval))
				{
					newSettings.minInterval = this.minInterval;
				}
				if (!isNaN(this.maxInterval))
				{
					newSettings.maxInterval = this.maxInterval;
				}
				// TODO: Find a way for this to be null
				newSettings.executeOnStart = this.executeOnStart;
			}
			return newSettings;
		}
		
		public function clone(): RecurranceSettings
		{
			return new RecurranceSettings(this.minInterval, this.maxInterval, this.executeOnStart, this.useSeconds);
		}
	}
}