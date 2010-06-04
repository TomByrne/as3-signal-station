package org.farmcode.sodalityLibrary.utils.recurring
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.sodality.advice.IAdvice;
	
	// TODO: Find a smarter way to continue if settings changed
	[Event(name="complete", type="flash.events.Event")]
	internal class RecurranceJob extends EventDispatcher
	{
		public var groupId: String;
		private var _specificSettings: RecurranceSettings;
		private var _baseSettings: RecurranceSettings;
		private var _running: Boolean;
		public var advice: IAdvice;
		private var pendingExecuteCall: DelayedCall;
		private var _id: int;
		private var _numExecutions: uint;
		
		public function RecurranceJob(id: int, advice: IAdvice = null, groupId: String = null, 
			specificSettings: RecurranceSettings = null, baseSettings: RecurranceSettings = null)
		{
			this._id = id;
			this._running = false;
			this._numExecutions = 0;
			
			this.advice = advice;
			this.groupId = groupId;
			this.specificSettings = specificSettings;
			this.baseSettings = baseSettings;
		}
		
		public function get id(): uint
		{
			return this._id;
		}
		
		[Property(toString="true", clonable="true")]
		public function get running(): Boolean
		{
			return this._running;
		}
		public function set running(value: Boolean): void
		{
			if (value != this.running)
			{
				this._running = value;
				this.clearPendingExecute();
				if (this.running)
				{
					if (this.settings.executeOnStart)
					{
						this.execute();
					}
					else
					{
						this.setupExecute();
					}
				}
			}
		}
		
		private function setupExecute(): void
		{
			var hasMin: Boolean = !isNaN(this.settings.minInterval);
			var hasMax: Boolean = !isNaN(this.settings.maxInterval);
			if (hasMin || hasMax)
			{
				// TODO: Need mroe checking for possible 0 values for delay
				var delay: Number = NaN;
				if (hasMin)
				{
					delay = this.settings.minInterval;
				}
				
				if (hasMax)
				{
					if (hasMin)
					{
						// TODO: Should provide some way to determine this distribution
						delay += (Math.random() * (this.settings.maxInterval - this.settings.minInterval));
					}
					else
					{
						delay = this.settings.maxInterval;
					}
				}
				
				if (!this.settings.useSeconds)
				{
					delay = Math.ceil(delay);
				}
				this.pendingExecuteCall = new DelayedCall(this.execute, delay, 
					this.settings.useSeconds);
				this.pendingExecuteCall.begin();
			}
			else
			{
				throw new Error("Cannot execute recurring job without interval");
			}
		}
		
		private function execute(): void
		{
			this._numExecutions++;
			this.dispatchEvent(new Event(Event.COMPLETE));
			this.setupExecute();
		}
		
		private function clearPendingExecute(): void
		{
			if (this.pendingExecuteCall != null)
			{
				this.pendingExecuteCall.clear();
				this.pendingExecuteCall = null;
			}
		}
		
		public function get numExecutions(): uint
		{
			return this._numExecutions;
		}
		
		public function restart(): void
		{
			this.running = false;
			this.running = true;
		}
		
		[Property(toString="true", clonable="true")]
		public function get baseSettings(): RecurranceSettings
		{
			return this._baseSettings;
		}
		public function set baseSettings(value: RecurranceSettings): void
		{
			if (value != this.baseSettings)
			{
				this._baseSettings = value;
				this.restart();
			}
		}
		
		[Property(toString="true", clonable="true")]
		public function get specificSettings(): RecurranceSettings
		{
			return this._specificSettings;
		}
		public function set specificSettings(value: RecurranceSettings): void
		{
			if (value != this.specificSettings)
			{
				this._specificSettings = value;
				this.restart();
			}
		}
		
		// TODO: Cache this
		public function get settings(): RecurranceSettings
		{
			var s: RecurranceSettings = null;
			if (this.specificSettings != null && this.baseSettings != null)
			{
				s = this.specificSettings.joinOn(this.baseSettings);
			}
			else if (this.specificSettings != null)
			{
				s = this.specificSettings;
			}
			else if (this.baseSettings != null)
			{
				s = this.baseSettings;
			}
			return s;
		}
	}
}