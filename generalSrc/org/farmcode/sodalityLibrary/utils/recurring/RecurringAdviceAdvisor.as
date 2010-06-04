package org.farmcode.sodalityLibrary.utils.recurring
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityLibrary.utils.recurring.adviceTypes.*;

	public class RecurringAdviceAdvisor extends DynamicAdvisor
	{
		public static const DEFAULT_GROUP: String = "_default";
		
		private var _groupSettings: Dictionary;
		private var _defaultSettings: RecurranceSettings;
		
		private var jobs: Array;
		private var jobId: uint;
		private var _running: Boolean;
		
		public function RecurringAdviceAdvisor(){
			super();
			
			this._running = true;
			
			this.jobId = 0;
			this.jobs = new Array();
			this._groupSettings = new Dictionary();
			
			this.addEventListener(AdvisorEvent.ADVISOR_ADDED, this.handleAdvisorAdded);
			this.addEventListener(AdvisorEvent.ADVISOR_REMOVED, this.handleAdvisorRemoved, false, int.MIN_VALUE);
		}
		
		[Property(toString="true", clonable="true")]
		public function get running(): Boolean
		{
			return this._running;
		}
		public function set running(value: Boolean): void
		{
			if (value != this._running)
			{
				this._running = value;
				this.refreshRunning();
			}
		}
		
		protected function refreshRunning(): void
		{
			for each (var job: RecurranceJob in this.jobs)
			{
				job.running = this.running && this.addedToPresident;
			}
		}
		
		private function handleAdvisorAdded(event: AdvisorEvent): void
		{
			this.refreshRunning();
		}
		
		private function handleAdvisorRemoved(event: AdvisorEvent): void
		{
			this.refreshRunning();
		}
		
		public function set defaultSettings(value: RecurranceSettings): void
		{
			this._defaultSettings = value;
			this.refreshJobSettings();
		}
		public function get defaultSettings(): RecurranceSettings
		{
			return this._defaultSettings;
		}
		
		protected function setGroupSetting(id: String, setting: RecurranceSettings): void
		{
			this._groupSettings[id] = setting;
			this.refreshJobSettings();
		}
		
		private function refreshJobSettings(): void
		{
			for each (var job: RecurranceJob in this.jobs)
			{
				if (job.groupId == RecurringAdviceAdvisor.DEFAULT_GROUP)
				{
					job.baseSettings = this.defaultSettings;
				}
				else
				{
					job.baseSettings = this._groupSettings[job.groupId];
				}
			}
		}
		
		[Property(toString="true", clonable="true")]
		public function get groupSettings(): Dictionary
		{
			return this._groupSettings;
		}
		public function set groupSettings(value: Dictionary): void
		{
			this._groupSettings = value;
		}
		
		[Trigger(triggerTiming="before")]
		public function onBeginRecurring(cause:IBeginRecurringAdviceAdvice): void{
			cause.addEventListener(AdviceEvent.EXECUTE, this.handleBeginExecute);
		}
		
		private function handleBeginExecute(event: AdviceEvent): void
		{
			var cause: IBeginRecurringAdviceAdvice = event.target as IBeginRecurringAdviceAdvice;
			cause.removeEventListener(event.type, this.handleBeginExecute);
			
			// Should we consider a begin advice that passes the exact same advice list through as being
			// a duplicate and thus not allowing it to add a new job?
			
			var baseSettings: RecurranceSettings = null;
			if (cause.settingsGroup != null)
			{
				baseSettings = this._groupSettings[cause.settingsGroup];
			}
			else if (cause.settings == null)
			{
				baseSettings = this.defaultSettings;
			}
			var job: RecurranceJob = new RecurranceJob(this.jobId, cause.recurringAdvice,
				cause.settingsGroup, cause.settings, baseSettings);
			cause.recurranceId = this.jobId;
			
			job.addEventListener(Event.COMPLETE, this.handleJobFire);
			this.jobId++;
			this.jobs.push(job);
			job.running = (this.running && this.addedToPresident);
		}
		
		private function handleJobFire(event: Event): void
		{
			var job: RecurranceJob = event.target as RecurranceJob;
			this.dispatchEvent(job.advice as Event);
		}
		
		[Trigger(triggerTiming="before")]
		public function onCeaseRecurring(cause: ICeaseRecurringAdviceAdvice): void{
			cause.addEventListener(AdviceEvent.EXECUTE, this.handleCeaseExecute);
		}
		
		private function handleCeaseExecute(event: AdviceEvent): void
		{
			var cause: ICeaseRecurringAdviceAdvice = event.target as ICeaseRecurringAdviceAdvice;
			cause.removeEventListener(event.type, this.handleCeaseExecute);
			
			var jIndex: int = this.getJobIndexById(cause.recurranceId);
			if (jIndex >= 0)
			{
				var job: RecurranceJob = this.jobs[jIndex];
				this.jobs.splice(jIndex, 1);
				job.removeEventListener(Event.COMPLETE, this.handleJobFire);
				job.running = false;
				if (job.numExecutions > 0 && job.advice is IRevertableAdvice)
				{
					var revertableAdvice: IRevertableAdvice = job.advice as IRevertableAdvice;
					if (revertableAdvice.doRevert)
					{
						var rAdvice: Advice = revertableAdvice.revertAdvice;
						rAdvice.executeBefore = cause;
						this.dispatchEvent(rAdvice);
					}
				}
			}
		}
		
		private function getJobIndexById(id: int): int
		{
			var target: int = -1;
			for (var i: uint = 0; i < this.jobs.length && target < 0; ++i)
			{
				var test: RecurranceJob = this.jobs[i];
				if (test.id == id)
				{
					target = i;
				}
			}
			return target;
		}
	}
}