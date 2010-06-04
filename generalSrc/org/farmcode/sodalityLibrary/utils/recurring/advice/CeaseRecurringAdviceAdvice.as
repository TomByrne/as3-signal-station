package org.farmcode.sodalityLibrary.utils.recurring.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.utils.recurring.adviceTypes.ICeaseRecurringAdviceAdvice;

	public class CeaseRecurringAdviceAdvice extends Advice implements ICeaseRecurringAdviceAdvice
	{
		private var _recurranceId:int;
		private var _revertFired: Boolean;

		public function CeaseRecurringAdviceAdvice(recurranceId:int=-1, revertFired: Boolean = true)
		{
			super();
			this.recurranceId = recurranceId;
			this.revertFired = revertFired;
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
		
		[Property(toString="true",clonable="true")]
		public function get recurranceId():int{
			return _recurranceId;
		}
		public function set recurranceId(value:int):void{
			//if(_recurranceId != value){
				_recurranceId = value;
			//}
		}
	}
}