package org.farmcode.sodality.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.hoborg.IPoolable;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.sodality.SodalityConstants;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.TriggerTiming;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.events.AdviceEvent;
	import org.farmcode.sodality.events.AdviceExecutionNodeEvent;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.triggers.IAdviceTrigger;
	use namespace SodalityNamespace;
	
	[Event(name="adviceExecute",type="org.farmcode.sodality.events.PresidentEvent")]
	public class AdviceExecutionNode extends EventDispatcher implements IPoolable
	{
		public function get parent():AdviceExecutionNode{
			return _parent;
		}
		public function set parent(value:AdviceExecutionNode):void{
			_parent = value;
		}
		public function get nodePool():ObjectPool{
			return _nodePool;
		}
		public function set nodePool(value:ObjectPool):void{
			_nodePool = value;
		}
		
		private var _parent:AdviceExecutionNode;
		
		public var generation:int;
		public var advice:IAdvice;
		public var triggers:Array = [];
		public var exhaustedTriggers:Array = [];
		public var executeBefore:Array = [];
		public var executeAfter:Array = [];
		public var dispatchEvents:Boolean;
		public var postponeExecution:Boolean;
		public var complete:Boolean = false;
		
		public var cursor:AdviceExecutionNode;
		private var time:String; // in relation to direct cause
		private var pendingExecution:Boolean;
		private var executedSelf:Boolean = false;
		private var _nodePool:ObjectPool;
		
		public function AdviceExecutionNode(){
		}
		public function addAdviceTree(tree:AdviceExecutionNode, before:Boolean):void{
			if(complete){
				throw new Error("Can't execute before or after advice after it has fired the AdviceEvent.COMPLETE event.");
			}
			tree.parent = this;
			if(!before){
				executeAfter.push(tree);
			}else if(executedSelf || cursor==this){
				executeAfter.unshift(tree);
			}else{
				executeBefore.unshift(tree);
			}
		}
		SodalityNamespace function execute(time:String):void{
			this.time = time;
			complete = false;
			executeNext();
		}
		protected function executeNext():void{
			checkTriggers();
			clearCursor();
			var time:String = TriggerTiming.AFTER;
			if(executeBefore.length){
				cursor = executeBefore.shift();
				time = TriggerTiming.BEFORE;
			}else if(!executedSelf){
				executedSelf = true;
				cursor = this;
			}else if(executeAfter.length){
				cursor = executeAfter.shift();
			}
			if(cursor){
				if(cursor==this){
					pendingExecution = true;
					if(dispatchEvents){
						var event:PresidentEvent = new PresidentEvent(PresidentEvent.ADVICE_EXECUTE,advice,advice.advisor);
						event.adviceExecutionNode = this;
						dispatchEvent(event);
					}
					if(!postponeExecution || !dispatchEvents){
						continueExecution();
					}
				}else{
					cursor.addEventListener(AdviceExecutionNodeEvent.EXECUTE_ADVICE,bubbleEvent);
					cursor.addEventListener(PresidentEvent.ADVICE_EXECUTE,bubbleEvent);
					cursor.addEventListener(Event.COMPLETE,adviceContinue);
					cursor.execute(time);
				}
			}else{
				complete = true;
				exhaustedTriggers = [];
				triggers = [];
				if(advice.hasEventListener(AdviceEvent.COMPLETE))advice.dispatchEvent(new AdviceEvent(AdviceEvent.COMPLETE));
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		SodalityNamespace function getNodeFor(advice:IAdvice):AdviceExecutionNode{
			if(this.advice==advice || Cloner.areClones(this.advice,advice)){
				return this;
			}
			var childArrays:Array = [cursor && cursor!=this?[cursor]:[],executeBefore,executeAfter];
			for each(var childArray:Array in childArrays){
				for each(var child:AdviceExecutionNode in childArray){
					var childRet:AdviceExecutionNode = child.getNodeFor(advice);
					if(childRet)return childRet;
				}
			}
			return null;
		}
		SodalityNamespace function continueExecution():void{
			if(pendingExecution){
				pendingExecution = false;
				if(advice.readyForExecution(parent?parent.advice:null)){
					advice.addEventListener(SodalityConstants.ADVICE_EXECUTE,executeAdvice);
					advice.addEventListener(AdviceEvent.CONTINUE,adviceContinue);
					advice.execute(parent?parent.advice:null,this.time);
				}else{
					executeNext();
				}
			}
		}
		protected function clearCursor():void{
			if(cursor){
				if(cursor==this){
					advice.removeEventListener(SodalityConstants.ADVICE_EXECUTE,executeAdvice);
					advice.removeEventListener(AdviceEvent.CONTINUE,adviceContinue);
				}else{
					cursor.removeEventListener(AdviceExecutionNodeEvent.EXECUTE_ADVICE,bubbleEvent);
					cursor.removeEventListener(PresidentEvent.ADVICE_EXECUTE,bubbleEvent);
					cursor.removeEventListener(Event.COMPLETE,adviceContinue);
					_nodePool.releaseObject(cursor);
				}
				cursor = null;
			}
		}
		SodalityNamespace function isDescendant(advideExecutionNode:AdviceExecutionNode):Boolean{
			if(advideExecutionNode==this || advideExecutionNode==cursor){
				return true;
			}
			var allChildren:Array = executeBefore.concat(executeAfter);
			var length:int = allChildren.length;
			for(var i:int=0; i<length; ++i){
				var child:AdviceExecutionNode = allChildren[i];
				if(child.isDescendant(advideExecutionNode)){
					return true;
				}
			}
			return false;
		}
		protected function executeAdvice(advice:IAdvice):void{
			var event:AdviceExecutionNodeEvent = new AdviceExecutionNodeEvent(AdviceExecutionNodeEvent.EXECUTE_ADVICE);
			event.advice = advice;
			event.targetNode = this;
			dispatchEvent(event);
		}
		protected function bubbleEvent(e:Event):void{
			dispatchEvent(e);
		}
		protected function adviceContinue(e:Event=null):void{
			executeNext()
		}
		/* the events that get dispatched from the triggers bubble up to the president,
		who then adds them to the appropriate node (usually this one).
		*/
		protected function checkTriggers():void{
			var i:int=0;
			while(i<triggers.length){
				var trigger:IAdviceTrigger = triggers[i];
				trigger.addEventListener(SodalityConstants.ADVICE_EXECUTE,executeAdvice);
				if(trigger.check(advice)){
					exhaustedTriggers.push(triggers.splice(i,1)[0]);
				}else{
					i++;
				}
				trigger.removeEventListener(SodalityConstants.ADVICE_EXECUTE,executeAdvice);
			}
		}
		SodalityNamespace function addNewTriggers(newTriggers:Array):void{
			for each(var childNode:AdviceExecutionNode in executeBefore){
				childNode.addNewTriggers(newTriggers);
			}
			for each(var trigger:IAdviceTrigger in newTriggers){
				if(triggers.indexOf(trigger)==-1 && exhaustedTriggers.indexOf(trigger)==-1){
					triggers.push(trigger);
				}
			}
			if(cursor && cursor!=this){
				cursor.addNewTriggers(newTriggers);
			}
			for each(childNode in executeAfter){
				childNode.addNewTriggers(newTriggers);
			}
		}
		SodalityNamespace function removeOldTriggers(oldTriggers:Array):void{
			for each(var childNode:AdviceExecutionNode in executeBefore){
				childNode.removeOldTriggers(oldTriggers);
			}
			for each(var trigger:IAdviceTrigger in oldTriggers){
				var index:int = triggers.indexOf(trigger);
				if(index!=-1){
					triggers.splice(index,1);
				}
				index = exhaustedTriggers.indexOf(trigger);
				if(index!=-1){
					exhaustedTriggers.splice(index,1);
				}
			}
			for each(childNode in executeAfter){
				childNode.removeOldTriggers(oldTriggers);
			}
		}
		public function reset():void{
			generation = 0;
			parent = null;
			advice = null;
			triggers = [];
			exhaustedTriggers = [];
			executeBefore = [];
			executeAfter = [];
			dispatchEvents = postponeExecution = false;
			complete = executedSelf = false;
		}
	}
}