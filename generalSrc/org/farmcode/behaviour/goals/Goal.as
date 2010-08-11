package org.farmcode.behaviour.goals
{
	import org.farmcode.behaviour.IBehavingItem;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.hoborg.ReadableObjectDescriber;
	
	public class Goal implements IGoal
	{
		
		/**
		 * @inheritDocs
		 */
		public function get goalChanged():IAct{
			if(!_goalChanged)_goalChanged = new Act();
			return _goalChanged;
		}
		
		[Property(toString="true",clonable="true")]
		public function get priority():uint{
			return _priority;
		}
		public function set priority(value:uint):void{
			if(_priority != value){
				this.performChangeAct();
				_priority = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get active():Boolean{
			return _active;
		}
		public function set active(value:Boolean):void{
			if(_priority != value){
				this.performChangeAct();
				_active = value;
			}
		}
		
		public function get progress():Number{
			return NaN;
		}
		
		public function get isComplete(): Boolean
		{
			return this.progress >= 1;
		}
		
		[Property(toString="true",clonable="true")]
		public function get behavingItem():IBehavingItem{
			return _behavingItem;
		}
		public function set behavingItem(value:IBehavingItem):void{
			if(_behavingItem != value){
				this.performChangeAct();
				_behavingItem = value;
			}
		}
		
		protected var _goalChanged:Act;
		
		private var _priority:uint;
		private var _active:Boolean;
		private var _behavingItem:IBehavingItem;
		
		public function Goal(priority:uint=0){
			this.priority = priority;
		}
		
		protected function performChangeAct(): void
		{
			if(_goalChanged)_goalChanged.perform(this);
		}
		
		public function toString(): String
		{
			return ReadableObjectDescriber.describe(this);
		}
	}
}