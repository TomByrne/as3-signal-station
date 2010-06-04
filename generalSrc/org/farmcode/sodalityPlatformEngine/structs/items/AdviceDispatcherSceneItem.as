package org.farmcode.sodalityPlatformEngine.structs.items
{
	import flash.utils.Dictionary;
	
	import org.farmcode.collections.DictionaryUtils;
	import org.farmcode.sodality.advice.IAdvice;
	
	public class AdviceDispatcherSceneItem extends SceneItem
	{
		public var dispatchingAdvices: Dictionary; // public for testing
		protected var _dispatchEnabled: Boolean;
		
		public function AdviceDispatcherSceneItem()
		{
			super(true);
			this.dispatchingAdvices = new Dictionary();
			this.dispatchEnabled = true;
		}
		
		public function get triggerIds(): Array
		{
			return DictionaryUtils.getKeys(this.dispatchingAdvices);
		}
		
		public function set dispatchEnabled(dispatchEnabled: Boolean): void
		{
			if (dispatchEnabled != this._dispatchEnabled)
			{
				this._dispatchEnabled = dispatchEnabled;
			}
		}
		public function get dispatchEnabled(): Boolean
		{
			return this._dispatchEnabled;
		}
		
		public function addDispatchedAdvice(triggerId: String, advice: IAdvice): void
		{
			var advices: Array = this.dispatchingAdvices[triggerId];
			if (advices == null)
			{
				advices = new Array();
				this.dispatchingAdvices[triggerId] = advices;
			}
			advices.push(advice);
		}
		
		public function removeDispatchedAdvice(triggerId: String, advice: IAdvice): Boolean
		{
			var removed: Boolean = false;
			var advices: Array = this.dispatchingAdvices[triggerId];
			if (advices != null)
			{
				var adIndex: int = advices.indexOf(advice);
				if (adIndex >= 0)
				{
					advices.splice(adIndex, advice);
					removed = true;
				}
				if (advices.length == 0)
				{
					delete this.dispatchingAdvices[triggerId];
				}
			}
			return removed;
		}
		
		public function setDispatchedAdvices(triggerId: String, advices: Array): void
		{
			this.removeDispatchedAdvices(triggerId);
			for (var i: uint = 0; i < advices.length; ++i)
			{
				var newAdvice: IAdvice = advices[i];
				this.addDispatchedAdvice(triggerId, newAdvice);
			}
		}
		
		public function removeDispatchedAdvices(triggerId: String): void
		{
			var currentAdvices: Array = this.dispatchingAdvices[triggerId];
			if (currentAdvices != null)
			{
				while (currentAdvices.length > 0)
				{
					var advice: IAdvice = currentAdvices.pop() as IAdvice;
					this.removeDispatchedAdvice(triggerId, advice);
				}
			}
		}
		
		protected function dispatchAdvices(triggerId: String): void
		{
			var advices: Array = this.dispatchingAdvices[triggerId];
			if (advices != null)
			{
				for (var i: uint = 0; i < advices.length; ++i)
				{
					if (this.dispatchEnabled)
					{
						dispatchEvent(advices[i]);
					}
				}
			}
		}
	}
}