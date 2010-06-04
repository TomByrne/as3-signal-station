package org.farmcode.sodalityPlatformEngine.scene
{
	import org.farmcode.sodalityPlatformEngine.parallax.IParallaxItem;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IAddSceneItemTriggersAdvice;
	import org.farmcode.sodalityPlatformEngine.parallax.adviceTypes.IRemoveSceneItemTriggersAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;
	import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.ISetSceneItemEnabledAdvice;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.events.AdviceEvent;

	public class SceneInteractivityAdvisor extends DynamicAdvisor
	{
		private var eventTriggerableItems: Array;
		
		public function SceneInteractivityAdvisor()
		{
			super();
			
			this.eventTriggerableItems = new Array();
		}
		
		[Trigger(triggerTiming="before")]
		public function handleSetSceneItemEnabled(cause: ISetSceneItemEnabledAdvice): void
		{
			cause.addEventListener(AdviceEvent.EXECUTE, this.handleSetItemEnabledExecute);
		}
		
		private function handleSetItemEnabledExecute(event: AdviceEvent): void
		{
			var cause: ISetSceneItemEnabledAdvice = event.target as ISetSceneItemEnabledAdvice;
			cause.removeEventListener(AdviceEvent.EXECUTE, this.handleSetItemEnabledExecute);
			
			var recognised: Boolean = true;
			
			var item: ISceneItem = cause.sceneItem;
			if (item is IParallaxItem)
			{
				var pItem: IParallaxItem = item as IParallaxItem;
				var itemDisplay: DisplayObject = pItem.parallaxDisplay.display;
				if (itemDisplay is InteractiveObject)
				{
					var iItemDisplay: InteractiveObject = itemDisplay as InteractiveObject;
					iItemDisplay.mouseEnabled = cause.enabled;
					if (iItemDisplay is DisplayObjectContainer)
					{
						var contItemDisplay: DisplayObjectContainer = iItemDisplay as DisplayObjectContainer;
						contItemDisplay.mouseChildren = cause.enabled;
					}
				}
				else
				{
					recognised = false;
				}
			}
			else
			{
				recognised = false;
			}
			
			if (!recognised)
			{
				throw new Error("Unable to set scene item enabled: " + item);
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function handleRemoveEventTriggers(cause: IRemoveSceneItemTriggersAdvice): void
		{
			var bundle: EventTriggersBundle = this.getEventTriggerBundle(cause.sceneItem, cause.eventTargetProp);
			if (bundle != null)
			{
				bundle.removeTriggeredAdvice(cause.eventTriggeredAdvice);
				if (!bundle.hasAdvice)
				{
					var bundleIndex: int = this.eventTriggerableItems.indexOf(bundle);
					this.eventTriggerableItems.splice(bundleIndex, 1);
				}
			}
		}
		
		[Trigger(triggerTiming="after")]
		public function handleAddEventTriggers(cause: IAddSceneItemTriggersAdvice): void
		{
			var bundle: EventTriggersBundle = this.getEventTriggerBundle(cause.sceneItem, cause.eventTargetProp);
			if (bundle == null)
			{
				bundle = new EventTriggersBundle(cause.sceneItem, cause.eventTargetProp);
				bundle.advisorDisplay = this.advisorDisplay;
				this.eventTriggerableItems.push(bundle);
			}
			bundle.addTriggeredAdvice(cause.eventTriggeredAdvice);
		}
		
		protected function getEventTriggerBundle(sceneItem: ISceneItem, targetProp: String): EventTriggersBundle
		{
			var target: EventTriggersBundle = null;
			for (var i: uint = 0; i < this.eventTriggerableItems.length && target == null; ++i)
			{
				var testBundle: EventTriggersBundle = this.eventTriggerableItems[i];
				if (testBundle.item == sceneItem && testBundle.eventTargetProp == targetProp)
				{
					target = testBundle;
				}
			}
			return target;
		}
	}
}

import org.farmcode.sodalityPlatformEngine.scene.ISceneItem;
import flash.utils.Dictionary;
import flash.events.IEventDispatcher;
import flash.events.Event;
import org.farmcode.sodality.advice.IAdvice;
import org.farmcode.sodality.advisors.DynamicAdvisor;
import org.farmcode.sodalityPlatformEngine.scene.adviceTypes.IDisposeSceneAdvice;
import org.farmcode.collections.DictionaryUtils;

class EventTriggersBundle extends DynamicAdvisor
{
	[Property(toString="true",clonable="true")]
	public var item: ISceneItem;
	[Property(toString="true",clonable="true")]
	public var eventTargetProp: String;
	public var eventTriggeredAdvice: Dictionary;
	private var _eventsEnabled: Boolean;
	
	public function EventTriggersBundle(item: ISceneItem, eventTargetProp: String)
	{
		this.item = item;
		this.eventTargetProp = eventTargetProp;
		this.eventTriggeredAdvice = new Dictionary();
		
		this.eventsEnabled = true;
	}
	
	public function set eventsEnabled(value: Boolean): void
	{
		if (value != this.eventsEnabled)
		{
			this._eventsEnabled = value;
			this.updateEvents();
		}
	}
	public function get eventsEnabled(): Boolean
	{
		return this._eventsEnabled;
	}
	
	protected function updateEvents(forceRemove: Boolean = false): void
	{
		if (this.eventsEnabled && !forceRemove)
		{
			for (var addEventName: String in this.eventTriggeredAdvice)
			{
				this.targetDispatcher.addEventListener(addEventName, this.handleEventTrigger);
			}
		}
		else
		{
			for (var remEventName: String in this.eventTriggeredAdvice)
			{
				this.targetDispatcher.removeEventListener(remEventName, this.handleEventTrigger);
			}
		}
	}
	
	public function removeTriggeredAdvice(triggeredAdvice: Dictionary): void
	{
		this.updateEvents(true);
		for (var removeEventName: String in triggeredAdvice)
		{
			var remAdvices: Array = triggeredAdvice[removeEventName];
			var currentAdvices: Array = this.eventTriggeredAdvice[removeEventName];
			if (currentAdvices != null)
			{
				for (var i: uint = 0; i < remAdvices.length; ++i)
				{
					var remAdvice: IAdvice = remAdvices[i];
					var remAdviceIndex: int = currentAdvices.indexOf(remAdvice);
					currentAdvices.splice(remAdviceIndex, 1);
				}
			}
			if (currentAdvices.length == 0)
			{
				delete this.eventTriggeredAdvice[removeEventName];
			}
		}
		this.updateEvents();
	}
	
	public function get hasAdvice(): Boolean
	{
		return DictionaryUtils.hasItem(this.eventTriggeredAdvice);
	}
	
	public function addTriggeredAdvice(triggeredAdvice: Dictionary): void
	{
		for (var addEventName: String in triggeredAdvice)
		{
			var newAdvices: Array = triggeredAdvice[addEventName];
			var currentAdvices: Array = this.eventTriggeredAdvice[addEventName];
			if (currentAdvices == null)
			{
				currentAdvices = new Array();
				this.eventTriggeredAdvice[addEventName] = currentAdvices;
			}
			
			for (var i: uint = 0; i < newAdvices.length; ++i)
			{
				var newAdvice: IAdvice = newAdvices[i];
				if (currentAdvices.indexOf(newAdvice) < 0)
				{
					currentAdvices.push(newAdvice);
				}
			}
		}
		this.updateEvents();
	}
	
	private function handleEventTrigger(event: Event): void
	{
		var triggeredAdvice: Array = this.eventTriggeredAdvice[event.type];
		for (var i: uint = 0; i < triggeredAdvice.length; ++i)
		{
			var advice: IAdvice = triggeredAdvice[i];
			this.dispatchEvent(advice as Event);
		}
	}
	
	protected function get targetDispatcher(): IEventDispatcher
	{
		var dispatcher: IEventDispatcher = null;
		if (this.eventTargetProp == null)
		{
			dispatcher = (this.item as IEventDispatcher);
		}
		else
		{
			dispatcher = this.item[this.eventTargetProp];
		}
		return dispatcher;
	}
	
	override public function toString(): String
	{
		return "[EventTriggersBundle item:" + this.item + ", eventTargetProp:" + this.eventTargetProp + "]";
	}
}