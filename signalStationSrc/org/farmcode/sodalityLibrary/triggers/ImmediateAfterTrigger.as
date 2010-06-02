package org.farmcode.sodalityLibrary.triggers
{
	import flash.events.IEventDispatcher;
	
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advice.IMemberAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.triggers.AdviceClassTrigger;

	public class ImmediateAfterTrigger extends AdviceClassTrigger
	{
		private var _executeBundles: Array;
		
		public function ImmediateAfterTrigger(adviceClass:Class = null, advice:Array=null)
		{
			super(adviceClass, advice, TriggerTiming.BEFORE);
			
			this._executeBundles = new Array();
		}
		
		override public function set triggerTiming(value:String):void
		{
			if (value == TriggerTiming.BEFORE)
			{
				super.triggerTiming = value;
			}
			else
			{
				throw new ArgumentError("ImmediateAfterTrigger must be set to triggerTiming BEFORE");
			}			
		}
		
		override public function check(advice:IAdvice) : Boolean
		{
			if (advice is this.adviceClass && this.hasAdvice)
			{
				var bundle: ExecuteBundle = new ExecuteBundle(advice, this.advice.slice());
				bundle.addEventListener(AdviceEvent.EXECUTE, this.handleBundleExecute);
				this._executeBundles.push(bundle);				
			}
			return true;
		}
		
		private function handleBundleExecute(event: AdviceEvent): void
		{
			var bundle: ExecuteBundle = event.target as ExecuteBundle;
			bundle.removeEventListener(AdviceEvent.EXECUTE, this.handleBundleExecute);
			var execIndex: int = this._executeBundles.indexOf(bundle);
			if (execIndex < 0)
			{
				throw new Error("Non-tracked Bundle execute caught");
			}
			else
			{
				this._executeBundles.splice(execIndex, 1)[0];
				for each(var singleAdvice:IAdvice in bundle.advice)
				{
					var dispatchTarget: IEventDispatcher = singleAdvice.advisor;
					if (dispatchTarget == null)
					{
						if (singleAdvice is IMemberAdvice && 
							(singleAdvice as IMemberAdvice) is IEventDispatcher)
						{
							var mAdvice: IMemberAdvice = singleAdvice as IMemberAdvice;
							dispatchTarget = mAdvice.subject as IEventDispatcher;
						}
						else
						{
							dispatchTarget = bundle.cause.advisor;
						}
					}
					addToAdvice(singleAdvice,bundle.cause,null,dispatchTarget);
				}
				bundle.release();
			}
		}
	}
}
import org.farmcode.memory.LooseReference;
import org.farmcode.sodality.advice.IAdvice;
import flash.events.EventDispatcher;
import org.farmcode.sodality.events.AdviceEvent;

class ExecuteBundle extends EventDispatcher
{
	private var _causeRef: LooseReference;
	public var advice: Array;
	
	public function ExecuteBundle(cause: IAdvice = null, advice: Array = null)
	{
		this.cause = cause;
		this.advice = advice;		
	}
	
	public function set cause(value: IAdvice): void
	{
		if (_causeRef != null)
		{
			this.cause.removeEventListener(AdviceEvent.EXECUTE, this.handleCauseExecute);
			_causeRef.release();
		}
		if (value != null)
		{
			this._causeRef = LooseReference.getNew(value);
			value.addEventListener(AdviceEvent.EXECUTE, this.handleCauseExecute);
		}else{
			_causeRef = null;
		}
	}
	public function get cause(): IAdvice
	{
		var target: IAdvice = null;
		if (this._causeRef != null)
		{
			target = this._causeRef.reference as IAdvice;
		}
		return target;
	}
	
	private function handleCauseExecute(event: AdviceEvent): void
	{
		this.dispatchEvent(new AdviceEvent(AdviceEvent.EXECUTE));
	}
	public function release(): void
	{
		_causeRef.release();
		_causeRef = null;
		advice = null;
	}
}