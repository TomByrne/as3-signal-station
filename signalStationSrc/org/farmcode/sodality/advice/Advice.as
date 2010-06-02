package org.farmcode.sodality.advice
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ReadableObjectDescriber;
	import org.farmcode.sodality.SodalityConstants;
	import org.farmcode.sodality.advisors.IAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.EventDispatcherClonable;
	
	//use namespace SodalityNamespace;
	
	/**
	 * <p>The Advice class is the basic event in the Sodality framework, generally a project will specify a set of Advice subclasses
	 * each with multiple 'adviceType's (in much the same way as Events specify different event types). The Advice class is a subclass of
	 * the Event class (and Advice always bubbles), and it can be dispatched (or 'executed' in the sodality framework) using:
	 * IEventDispatcher.dispatchEvent(advice);
	 * </p>
	 * <p>Using the Advisor class other advice can then be executed, most commonly this would be the MethodAdvice class.</p>
	 */
	[Event(name="execute",type="org.farmcode.sodality.events.AdviceEvent")]
	[Event(name="continue",type="org.farmcode.sodality.events.AdviceEvent")]
	[Event(name="complete",type="org.farmcode.sodality.events.AdviceEvent")]
	public class Advice extends Event implements IAdvice, IEventDispatcher, IPoolable
	{
		/** The Advisor which has dispatched this advice
		 */
		[Property(toString="true",clonable="true")]
		public function get advisor(): IAdvisor{
			return _advisor?_advisor:(target as IAdvisor);
		}
		public function set advisor(value: IAdvisor):void{
			if(_advisor!=value){
				_advisor = value;
			}
		}
		
		private var _advisor:IAdvisor;
		private var _executeBefore:IAdvice;
		private var _executeAfter:IAdvice;
		private var _abortable:Boolean = true;
		private var _aborted:Boolean = false;
		private var _executing:Boolean = false;
		
		public function Advice(abortable:Boolean=true){
			super(SodalityConstants.ADVICE_EXECUTE);
			this.abortable = abortable;
		}
		
		[Property(toString="false",clonable="true")]
		public function set executeBefore(advice:IAdvice): void
		{
			this._executeBefore = advice;
		}
		public function get executeBefore(): IAdvice
		{
			return this._executeBefore;
		}
		[Property(toString="false",clonable="true")]
		public function set executeAfter(advice:IAdvice): void
		{
			this._executeAfter = advice;
		}
		public function get executeAfter(): IAdvice
		{
			return this._executeAfter;
		}
		
		/** Whether or not this advice will be aborted if something goes wrong
		 */
		[Property(toString="true",clonable="true")]
		public function set abortable(abortable: Boolean): void{
			this._abortable = abortable;
		}
		public function get abortable(): Boolean{
			return this._abortable;
		}
		public function set aborted(aborted: Boolean): void{
			this._aborted = aborted;
		}
		public function get aborted(): Boolean{
			return this._aborted;
		}
		
		protected function get executing(): Boolean
		{
			return this._executing;
		}
		
		public function readyForExecution(cause:IAdvice):Boolean{
			if(cause && !aborted)aborted = cause.aborted;
			return (!aborted || !abortable);
		}
		/**
		 * Called by the President to append a call to the Advice's pending calls.
		 * @private
		 */
		public function execute(cause:IAdvice, time:String):void{
			if(!_executing){
				_executing = true;
				if(hasEventListener(AdviceEvent.EXECUTE))dispatchEvent(new AdviceEvent(AdviceEvent.EXECUTE));
				_execute(cause, time);
			}
		}
		protected function _execute(cause:IAdvice, time:String):void{
			// override me
			adviceContinue();
		}
		public function adviceContinue():void{
			if(_executing){
				_executing = false;
				if(hasEventListener(AdviceEvent.CONTINUE))dispatchEvent(new AdviceEvent(AdviceEvent.CONTINUE));
			}else {
				throw new Error("Advice.adviceContinue: this advice has already been continued");
			}
		}
		public function cloneAdvice():IAdvice{
			var ret:Advice = clone() as Advice;
			if(eventDispatcher)ret.eventDispatcher = eventDispatcher.clone(ret); // this locks the listeners
			ret.advisor = advisor;
			ret.aborted = false;
			return ret;
		}
		override public function clone():Event{
			return Cloner.clone(this) as Event;
		}
		
		override public function toString(): String{
			return ReadableObjectDescriber.describe(this);
		}
		public function reset():void{
			_advisor = null;
			_executeBefore = null;
			_executeAfter = null;
			_abortable = true;
			_aborted = false;
			_executing = false;
		}
		
		
		// Event Dispatching
		[Property(toString="false",clonable="true")]
		public var eventDispatcher:EventDispatcherClonable;
		
		public function get ensuredEventDispatcher(): IEventDispatcher {
			if (!this.eventDispatcher)
			{
				this.eventDispatcher = new EventDispatcherClonable(this);
			}
			return this.eventDispatcher;
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{
			this.ensuredEventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			this.ensuredEventDispatcher.removeEventListener(type, listener, useCapture);
		}
		public function dispatchEvent(event:Event):Boolean{
			return this.ensuredEventDispatcher.dispatchEvent(event);
		}
		public function hasEventListener(type:String):Boolean{
			return this.ensuredEventDispatcher.hasEventListener(type);
		}
		public function willTrigger(type:String):Boolean{
			return this.ensuredEventDispatcher.willTrigger(type);
		}
	}
}