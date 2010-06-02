package org.farmcode.sodality
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import org.farmcode.compiler.MetadataConfirmer;
	import org.farmcode.hoborg.Cloner;
	import org.farmcode.hoborg.ObjectPool;
	import org.farmcode.reflection.ReflectionUtils;
	import org.farmcode.sodality.advice.*;
	import org.farmcode.sodality.advisors.*;
	import org.farmcode.sodality.events.AdviceExecutionNodeEvent;
	import org.farmcode.sodality.events.AdvisorEvent;
	import org.farmcode.sodality.events.DynamicAdvisorEvent;
	import org.farmcode.sodality.events.NonVisualAdvisorEvent;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.triggerResponseCache.AdviceClassTriggerResponseCache;
	import org.farmcode.sodality.triggerResponseCache.ITriggerResponseCache;
	import org.farmcode.sodality.triggers.*;
	import org.farmcode.sodality.utils.*;
	
	use namespace SodalityNamespace;
	
	[Event(name="advisorAdded",type="org.farmcode.sodality.PresidentEvent")]
	[Event(name="advisorRemoved",type="org.farmcode.sodality.PresidentEvent")]
	[Event(name="executionBegin",type="org.farmcode.sodality.events.PresidentEvent")]
	[Event(name="adviceExecute",type="org.farmcode.sodality.events.PresidentEvent")]
	[Event(name="executionEnd",type="org.farmcode.sodality.events.PresidentEvent")]
	
	/**
	 * Sodality Version 2.0
	 * 
	 * The President class is at the core of the Sodality event framework. It acts as the central controller for the event framework.
	 * <br>
	 * The Sodality framework is a discreet event system which allows parts of a project to work together without knowing anything about
	 * one another.
	 */
	public class President extends EventDispatcher
	{
		private static const REQUIRED_META_TAGS: Array = ["Property", "Trigger", "Advice"];
		private static const RECURSION_LIMIT:int = 0xff;
		
		// There doesn't appear to be a security checking method that doesn't involve error catching
		static protected function securityCheck(displayObject:DisplayObject):Boolean{
			var loader:Loader = (displayObject as Loader);
			if(loader && loader.contentLoaderInfo.url){
				try{
					loader.content;
					return true;
				}catch(e:Error){
					return false;
				}
			}
			return true;
		}
		
		public function get headAdvisor():IEventDispatcher{
			return _headAdvisor;
		}
		public function set adviceTriggerFactory(adviceTriggerFactory: AdviceTriggerFactory): void{
			this._adviceTriggerFactory = adviceTriggerFactory;
		}
		public function get adviceTriggerFactory():AdviceTriggerFactory{
			return _adviceTriggerFactory;
		}
		public function set adviceFactory(adviceFactory: AdviceFactory): void{
			this._adviceFactory = adviceFactory;
		}
		public function get adviceFactory():AdviceFactory{
			return _adviceFactory;
		}
		
		public function set triggerResponseCache(triggerResponseCache:ITriggerResponseCache): void{
			this._triggerResponseCache = triggerResponseCache;
		}
		public function get triggerResponseCache():ITriggerResponseCache{
			return _triggerResponseCache;
		}
		
		SodalityNamespace function get advisorRoot():AdvisorNode{
			return _advisorRoot;
		}
		SodalityNamespace function get advisorList():Array{
			return advisorBundles;
		}
		
		/**
		 * Setting this to false will prevent the President from dispatching any events (to optimise performance).
		 * Most of the time the President's event are used only for debugging.
		 */
		public var dispatchEvents:Boolean = true;
		
		/**
		 * Setting this to true prevent any advice being executed until the continueExecution method is called on the
		 * PresidentEvent.ADVICE_EXECUTE events which are fired from the president, this is useful for step-through debuggers.
		 */
		public var postponeExecution:Boolean = false;
		
		private var _headAdvisor:DisplayObject;
		protected var advisorBundles:Array; // this should be a dictionary I think
		protected var executingNodes:Dictionary = new Dictionary();
		protected var _advisorRoot:AdvisorNode;
		protected var dynamicTriggers:Dictionary = new Dictionary();
		
		private var _adviceTriggerFactory: AdviceTriggerFactory;
		private var _adviceFactory: AdviceFactory;
		private var _triggerResponseCache:ITriggerResponseCache;
		
		private var _nodePool:ObjectPool = new ObjectPool(AdviceExecutionNode);
		
		/**
		 * The headAdvisor parameter in the President constructor will (usually) be a top-level DisplayObject, all advice which bubbles up
		 * to this DisplayObject will be caught by this President and the events bubbling will cease. It is possible to use two Presidents within
		 * one project, but keep in mind that each piece of advice will only reach one President (the President whose headAdvisor is reached first
		 * by the bubbling Advice).
		 */
		public function President(headAdvisor:DisplayObject){
			super();
			
			this.validateProjectSettings();
			
			// Forced includes
			var includeClass: Class = AdviceClassTrigger;
			
			this.advisorBundles = new Array();
			
			this.adviceTriggerFactory = new AdviceTriggerFactory();
			this.adviceFactory = new AdviceFactory();
			
			this.triggerResponseCache = new AdviceClassTriggerResponseCache();
			
			this._advisorRoot = new AdvisorNode();
			
			_headAdvisor = headAdvisor;
			if(_headAdvisor is IAdvisor)
			{
				addAdvisor(_headAdvisor as IAdvisor);
				this.dispatchAddEvents(_headAdvisor);
			}
			
			// Priorities leave some space to allow for other objects to do something to the advisor
			// Before it reaches the president
			_headAdvisor.addEventListener(Event.ADDED, this.onDisplayObjectAdded, false, int.MAX_VALUE / 2);
			_headAdvisor.addEventListener(Event.REMOVED, this.onDisplayObjectRemoved, false, int.MIN_VALUE / 2);
			
			_headAdvisor.addEventListener(NonVisualAdvisorEvent.ADVISOR_ADD_REQUEST, this.onNonVisualAdvisorAdded);
			_headAdvisor.addEventListener(NonVisualAdvisorEvent.ADVISOR_REMOVE_REQUEST, this.onNonVisualAdvisorRemoved);
		}
		
		/**
		 * Checks if the project is set up correctly to handle sodality
		 */
		protected function validateProjectSettings(): void
		{
			if (!MetadataConfirmer.confirm(REQUIRED_META_TAGS,MetadataTest))
			{
				var msg: String = "Your project settings aren't compatible with Sodality. ";
				msg += "Please ensure you have '-keep-as3-metadata+=";
				msg += REQUIRED_META_TAGS.join(",");
				msg += "' in your \"Additional Compiler Arguments\"";
				throw new Error(msg);
			}
		}
				
		protected function onDisplayObjectAdded(event: Event): void{
			dispatchAddEvents(event.target);
		}
		protected function onNonVisualAdvisorAdded(event: NonVisualAdvisorEvent): void{
			dispatchAddEvents(event.advisor)
		}
		protected function dispatchAddEvents(object:*):void{
			var advisor: IAdvisor = object as IAdvisor;
			if (advisor && !getBundleForAdvisor(advisor)){
				addAdvisor(advisor);
				var cast:INonVisualAdvisor = (advisor as INonVisualAdvisor);
				var dispatcher:IEventDispatcher = (cast?cast.advisorDisplay:advisor);
				if(dispatcher && dispatcher.willTrigger(AdvisorEvent.ADVISOR_ADDED)){
					dispatcher.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_ADDED,true));
				}
			}
			if (object is DisplayObjectContainer){
				var container: DisplayObjectContainer = object as DisplayObjectContainer;
				if(securityCheck(container)){
					for (var i: uint = 0; i < container.numChildren; ++i){
						var child: DisplayObject = container.getChildAt(i);
						dispatchAddEvents(child);
					}
				}
			}
		}
		
		protected function createAdvisorBundle(advisor: IAdvisor):AdvisorBundle{
			var bundle: AdvisorBundle = new AdvisorBundle(advisor);
			bundle.triggers = createTriggers(advisor);
			for (var i: uint = 0; i < bundle.triggers.length; ++i)
			{
				var trigger: IAdviceTrigger = bundle.triggers[i];
				this.triggerResponseCache.addTrigger(trigger);
			}
			return bundle;
		}
		protected function createTriggers(advisor:IAdvisor): Array{
			var classDesc: XML = ReflectionUtils.describeType(advisor);
			var triggers: Array = new Array();
			
			var memberList: XMLList = classDesc.descendants().(name()=="method"||name()=="variable"||name()=="accessor");
			for each(var memberNode:XML in memberList){
				var newTriggers: Array = this.createMemberTriggers(memberNode,advisor);
				triggers = triggers.concat(newTriggers);
			}
			return triggers;
		}
		protected function createMemberTriggers(memberNode: XML, advisor:IAdvisor): Array{
			var triggers: Array = new Array();
			var adviceList: Array = new Array();
			
			var metaDataXML: XMLList = memberNode.metadata;
				
			var trigger:IMemberAdviceTrigger;
			var advice:IMemberAdvice;
			var tot:Number = metaDataXML.length();
			var gotMember:Boolean;
			for(var i:int=0; i<tot; ++i){
				var metaData:XML = metaDataXML[i];
				var metaName:String = metaData.attribute("name").toLowerCase();
				switch(metaName){
					case "trigger":
						trigger = _adviceTriggerFactory.createAdviceTrigger(metaData,memberNode);
						if(trigger){
							//trigger.advice = [implicitAdvice];
							triggers.push(trigger);
						}
						break;
					case "advice":
						advice = _adviceFactory.createAdvice(advisor,metaData,memberNode);
						if(advice){
							adviceList.push(advice);
							if(!gotMember && advice is IMemberAdvice){
								gotMember = true;
							}
						}
						break;
				}
			}
			if(triggers.length){
				if(!gotMember){
					advice = _adviceFactory.getImplicitAdvice(advisor,memberNode);
					if(advice)adviceList.push(advice);
				}
				for each(trigger in triggers){
					trigger.advice = adviceList;
				}
			}
			return triggers;
		}
		
		public function addAdvisor(advisor: IAdvisor): void
		{
			if(this.getBundleForAdvisor(advisor)){
				trace("WARNING: Advisor already added: "+advisor);
				return;
			}
			advisor.addEventListener(SodalityConstants.ADVICE_EXECUTE,onExecute);
			var bundle: AdvisorBundle = this.createAdvisorBundle(advisor);
			this.advisorBundles.push(bundle);
			
					
			// Search the advisor's lineage for another advisor. If it has a parent advisor then
			// it is assumed it has been registered already in the president
			var advisorParent: IAdvisor = null;
			var advisorDisplay:DisplayObject;
			if(advisor is IPresidentAwareAdvisor){
				(advisor as IPresidentAwareAdvisor).president = this;
			}
			
			var nonVisAdv:INonVisualAdvisor = advisor as INonVisualAdvisor;
			if(nonVisAdv){
				advisorDisplay = nonVisAdv.advisorDisplay;
				nonVisAdv.addedToPresident = true;
				if (nonVisAdv.willTrigger(AdvisorEvent.ADVISOR_ADDED))
				{
					nonVisAdv.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_ADDED,true));
				}
			}else{
				var disObjAdv:DisplayObject = (advisor as DisplayObject);
				if(disObjAdv){
					advisorDisplay = disObjAdv;
				}
			}
			var dynAdv:IDynamicAdvisor = (advisor as IDynamicAdvisor);
			if(dynAdv){
				dynAdv.addEventListener(DynamicAdvisorEvent.TRIGGERS_CHANGED, onDynamicTriggersChanged);
				checkDynamicTriggers(dynAdv);
			}
			
			if (advisorDisplay)
			{
				var displayParent: DisplayObjectContainer = advisorDisplay.parent;
				
				// Go up through display list to find advisor parent, terminating at the head 
				// advisor (ensures stays within president scope)
				while (advisorParent == null && displayParent != null && 
					displayParent != this._headAdvisor.parent)
				{
					if (displayParent is IAdvisor)
					{
						advisorParent = displayParent as IAdvisor;
					}
					else
					{
						displayParent = displayParent.parent;
					}
				}
			}
			
			// If an advisor was found in the display list lineage, then we will place this advisor
			// right under it in our own tree. Else we will place the advisor in the root of tree
			if (advisorParent == null)
			{
				// Add in root
				this.advisorRoot.addChild(bundle);
				dispatchPresidentEvent(PresidentEvent.ADVISOR_ADDED,null,advisor,bundle);
			}
			else
			{
				// Add in relevant place under advisorParent
				var parentBundle: AdvisorBundle = this.getBundleForAdvisor(advisorParent);
				if (parentBundle == null)
				{
					throw new Error("trying to add advisor with an unregistered advisor parent");
				}
				else
				{
					var parentNode: AdvisorNode = this.advisorRoot.findAdvisorNode(parentBundle);
					if (parentNode == null)
					{
						throw new Error("trying to add advisor with an unregistered advisor parent");
					}
					else
					{
						parentNode.addChild(bundle);
						dispatchPresidentEvent(PresidentEvent.ADVISOR_ADDED,null,advisor,bundle);
					}
				}
			}
			// distribute triggers to currently executing AdviceExecutionNodes
			var newTriggers:Array = getTriggers(bundle);
			for(var i:* in executingNodes){
				var executionNode:AdviceExecutionNode = (i as AdviceExecutionNode);
				executionNode.addNewTriggers(newTriggers);
			}
		}
		
		protected function onDynamicTriggersChanged(e:DynamicAdvisorEvent):void{
			checkDynamicTriggers(e.target as IDynamicAdvisor);
		}
		protected function checkDynamicTriggers(dynamicAdvisor:IDynamicAdvisor):void{
			var oldTriggers:Array = dynamicTriggers[dynamicAdvisor];
			if(!oldTriggers){
				oldTriggers = dynamicTriggers[dynamicAdvisor] = [];
			}
			var removed:Array = [];
			var trigger:IAdviceTrigger;
			for each(trigger in oldTriggers){
				if(dynamicAdvisor.triggers.indexOf(trigger)==-1){
					removed.push(trigger);
					triggerResponseCache.removeTrigger(trigger);
				}
			}
			var added:Array = [];
			for each(trigger in dynamicAdvisor.triggers){
				if(oldTriggers.indexOf(trigger)==-1){
					added.push(trigger);
					triggerResponseCache.addTrigger(trigger);
				}
			}
			dynamicTriggers[dynamicAdvisor] = dynamicAdvisor.triggers.slice();
			
			// add/remove triggers to/from currently executing AdviceExecutionNodes
			for(var i:* in executingNodes){
				var executionNode:AdviceExecutionNode = (i as AdviceExecutionNode);
				executionNode.addNewTriggers(added);
				executionNode.removeOldTriggers(removed);
			}
		}
		
		private function dispatchPresidentEvent(eventType:String, advice:IAdvice=null, advisor:IAdvisor=null, advisorBundle:AdvisorBundle=null, adviceExecutionNode:AdviceExecutionNode=null): void{
			if(dispatchEvents && this.hasEventListener(eventType)){
				var event: PresidentEvent = new PresidentEvent(eventType,advice,advisor);
				event.advisorBundle = advisorBundle;
				event.adviceExecutionNode = adviceExecutionNode;
				this.dispatchEvent(event);
			}
		}
		
		protected function onDisplayObjectRemoved(event:Event): void{
			if(event.target!=_headAdvisor || event.target==event.currentTarget){
				dispatchRemoveEvents(event.target);
			}
		}
		protected function onNonVisualAdvisorRemoved(event: NonVisualAdvisorEvent): void{
			dispatchRemoveEvents(event.advisor);
		}
		protected function dispatchRemoveEvents(object:*):void{
			if (object is DisplayObjectContainer){
				var container: DisplayObjectContainer = object as DisplayObjectContainer;
				if(securityCheck(container)){
					for (var i: uint = 0; i < container.numChildren; ++i){
						var child: DisplayObject = container.getChildAt(i);
						dispatchRemoveEvents(child);
					}
				}
			}
			var advisor: IAdvisor = object as IAdvisor;
			if (advisor){
				if(advisor is INonVisualAdvisor){
					var display:DisplayObject = (advisor as INonVisualAdvisor).advisorDisplay;
					if(display && display.willTrigger(AdvisorEvent.ADVISOR_REMOVED))display.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_REMOVED,true));
				}else if (advisor.willTrigger(AdvisorEvent.ADVISOR_REMOVED)){
					advisor.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_REMOVED,true));
				}
				var cast:INonVisualAdvisor = (advisor as INonVisualAdvisor);
				var dispatcher:IEventDispatcher = (cast?cast.advisorDisplay:advisor);
				if(dispatcher && dispatcher.willTrigger(AdvisorEvent.ADVISOR_REMOVED)){
					dispatcher.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_REMOVED,true));
				}
				removeAdvisor(advisor);
			}
		}
		
		public function removeAdvisor(advisor: IAdvisor): void
		{
			var advisorBundle: AdvisorBundle = this.getBundleForAdvisor(advisor);
			if (advisorBundle == null)
			{
				//trace("WARNING: trying to remove non-tracked advisor");
				//throw new Error("Try to remove non-tracked advisor");
			}
			else
			{
				var index: int = this.advisorBundles.indexOf(advisorBundle);
				this.advisorBundles.splice(index, 1);
				if(advisor is INonVisualAdvisor){
					var nvAdvisor:INonVisualAdvisor = (advisor as INonVisualAdvisor);
					nvAdvisor.addedToPresident = false;
					if (nvAdvisor.willTrigger(AdvisorEvent.ADVISOR_REMOVED))
					{
						nvAdvisor.dispatchEvent(new AdvisorEvent(advisor,AdvisorEvent.ADVISOR_REMOVED,true));
					}
				}
				
				var found: Boolean = this.advisorRoot.removeChildRecursively(advisorBundle);
				if (found)
				{
					// remove triggers from currently executing AdviceExecutionNodes
					var oldTriggers:Array = getTriggers(advisorBundle);
					for(var j:* in executingNodes){
						var executionNode:AdviceExecutionNode = (j as AdviceExecutionNode);
						executionNode.removeOldTriggers(oldTriggers);
					}
					for (var i: uint = 0; i < oldTriggers.length; ++i)
					{
						var oldTrigger: IAdviceTrigger = oldTriggers[i];
						triggerResponseCache.removeTrigger(oldTrigger);
					}
					
					dispatchPresidentEvent(PresidentEvent.ADVISOR_REMOVED,null,advisor,advisorBundle);
				}
				else
				{
					trace("WARNING: trying to remove non-tracked advisor: "+advisor);					
				}
				
				if (advisor is IDynamicAdvisor)
				{
					delete this.dynamicTriggers[advisor];
				}
			}
			advisor.removeEventListener(SodalityConstants.ADVICE_EXECUTE,onExecute);
		}
		
		SodalityNamespace function getBundleForAdvisor(advisor: IAdvisor): AdvisorBundle
		{
			var target: AdvisorBundle = null;
			
			for (var i: uint = 0; i < this.advisorBundles.length && target == null; ++i)
			{
				var testBundle: AdvisorBundle = this.advisorBundles[i] as AdvisorBundle;
				if (testBundle.advisor == advisor)
				{
					target = testBundle;
				}
			}
			
			return target;
		}
		
		protected function createExecutionNode(advice:IAdvice, gen:int=0):AdviceExecutionNode{
			if(gen>RECURSION_LIMIT){
				throw new Error("President recursion limit has been reached; there is probably a circular reference");
			}
			var ret:AdviceExecutionNode = _nodePool.takeObject();
			ret.nodePool = _nodePool;
			ret.advice = advice.cloneAdvice();
			ret.generation = gen;
			ret.dispatchEvents = this.dispatchEvents;
			ret.postponeExecution = (this.postponeExecution && this.hasEventListener(PresidentEvent.ADVICE_EXECUTE));
			advice.executeAfter = null;
			advice.executeBefore = null;
			ret.triggers = triggerResponseCache.getTriggers(advice).slice();

			return ret;
		}
		
		protected function getTriggers(bundle:AdvisorBundle):Array{
			var triggers:Array = bundle.triggers?bundle.triggers.slice():[];
			if(bundle.advisor is IDynamicAdvisor){
				triggers = triggers.concat((bundle.advisor as IDynamicAdvisor).triggers);
			}
			return triggers;
		}
		protected function getAdvisorTrail(advisor:IAdvisor):Array{
			var ret:Array = [];
			var node:AdvisorNode = advisorRoot.findAdvisorNode(advisor);
			while(node){
				if(node.bundle)ret.push(node.bundle);
				node = node.parent;
			}
			return ret;
		}
		protected function onNodeExecute(e:AdviceExecutionNodeEvent):void{
			var parentAdvice:IAdvice = (e.advice.executeBefore?e.advice.executeBefore:e.advice.executeAfter);
			var parentNode:AdviceExecutionNode = e.targetNode;
			if(!parentAdvice || (parentNode.advice!=parentAdvice && !Cloner.areClones(parentNode.advice,parentAdvice))){
				parentNode = null;
			}
			onExecute(e.advice, parentNode, parentAdvice);
		}
		protected function onExecute(advice:IAdvice, parentNode:AdviceExecutionNode=null, parentAdvice:IAdvice=null):void{
			if(!parentAdvice)parentAdvice = (advice.executeBefore?advice.executeBefore:advice.executeAfter);
			if(parentAdvice){
				if(!parentNode){
					parentNode = findExecutionNode(parentAdvice);
				}
				if(parentNode)
				{
					var before: Boolean = (advice.executeBefore != null);
					parentNode.addAdviceTree(createExecutionNode(advice,parentNode.generation+1), before);
				}
				else
				{
					throw new Error("Couldn't find AdviceExecutionNode for advice: "+parentAdvice);
				}
			}else{
				var adviceTree:AdviceExecutionNode = createExecutionNode(advice);
				beginAdvice(adviceTree);
			}
			if(advice is Event){
				(advice as Event).stopImmediatePropagation();
			}
		}
		protected function beginAdvice(node:AdviceExecutionNode):void{
			executingNodes[node] = true;
			node.addEventListener(PresidentEvent.ADVICE_EXECUTE,onAdviceExecute);
			node.addEventListener(Event.COMPLETE,adviceFinished);
			node.addEventListener(AdviceExecutionNodeEvent.EXECUTE_ADVICE,onNodeExecute);
			dispatchPresidentEvent(PresidentEvent.EXECUTION_BEGIN, node.advice, node.advice.advisor, null, node);
			if(!postponeExecution)node.execute(null);
		}
		protected function adviceFinished(e:Event):void{
			var node:AdviceExecutionNode = (e.target as AdviceExecutionNode);
			delete executingNodes[node]
			
			node.removeEventListener(PresidentEvent.ADVICE_EXECUTE,onAdviceExecute);
			node.removeEventListener(Event.COMPLETE,adviceFinished);
			node.removeEventListener(AdviceExecutionNodeEvent.EXECUTE_ADVICE,onNodeExecute);
			
			dispatchPresidentEvent(PresidentEvent.EXECUTION_END, node.advice, node.advice.advisor, null, node);
			_nodePool.releaseObject(node);
		}
		protected function onAdviceExecute(e:PresidentEvent):void{
			if(dispatchEvents)dispatchEvent(e);
		}
		
		protected function findExecutionNode(advice:IAdvice):AdviceExecutionNode{
			for(var i:* in executingNodes){
				var node:AdviceExecutionNode = (i as AdviceExecutionNode);
				var childRet:AdviceExecutionNode = node.getNodeFor(advice);
				if(childRet)return childRet;
			}
			return null;
		}
	}
}
class MetadataTest
{
	[Advice]
	public var advice: String;
	[Trigger]
	public var trigger: String;
	[Property]
	public var property: String;
}