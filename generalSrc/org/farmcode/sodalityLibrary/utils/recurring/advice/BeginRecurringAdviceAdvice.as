package org.farmcode.sodalityLibrary.utils.recurring.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.utils.recurring.JobDetails;
	import org.farmcode.sodalityLibrary.utils.recurring.RecurranceSettings;
	import org.farmcode.sodalityLibrary.utils.recurring.adviceTypes.IBeginRecurringAdviceAdvice;

	public class BeginRecurringAdviceAdvice extends Advice implements IBeginRecurringAdviceAdvice
	{
		private var _recurringAdvice:IAdvice;
		private var _settingsGroup: String;
		private var _settings: RecurranceSettings;
		private var _revertFired: Boolean;
		
		[Property(clonable="true")]
		public var jobDetails: JobDetails;
		
		public function BeginRecurringAdviceAdvice(recurringAdvice:IAdvice=null){
			super();
			this.recurringAdvice = recurringAdvice;
			this.jobDetails = new JobDetails();
			this.revertFired = true;
		}
		
		public function get recurranceId():int{
			return this.jobDetails.id;
		}
		public function set recurranceId(value:int):void{
			//if(_recursionId != value){
				jobDetails.id = value;
			//}
		}
		[Property(toString="true",clonable="true")]
		public function get recurringAdvice():IAdvice{
			return _recurringAdvice;
		}
		public function set recurringAdvice(value:IAdvice):void{
			//if(_recurringAdvice != value){
				_recurringAdvice = value;
			//}
		}
		
		[Property(toString="true", clonable="true")]
		public function get revertFired(): Boolean
		{
			return this._revertFired;
		}
		public function set revertFired(value: Boolean): void
		{
			this._revertFired = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get settings(): RecurranceSettings
		{
			return this._settings;
		}
		public function set settings(value: RecurranceSettings): void
		{
			this._settings = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get settingsGroup(): String
		{
			return this._settingsGroup;
		}
		public function set settingsGroup(value: String): void
		{
			this._settingsGroup = value;
		}
		
		public function get doRevert(): Boolean
		{
			return true;
		}
		public function get revertAdvice(): Advice
		{
			return new CeaseRecurringAdviceAdvice(this.recurranceId, this.revertFired);
		}
	}
}