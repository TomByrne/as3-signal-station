package org.farmcode.acting.bubbling
{
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;

	public class BubbleHub implements IBubbleHub
	{
		/**
		 * @inheritDoc
		 */
		public function get onBubbled():IAct{
			if(!_onBubbled)_onBubbled = new Act();
			return _onBubbled;
		}
		
		public function get bubblableActs():Array{
			return _bubblableActs;
		}
		public function set bubblableActs(value:Array):void{
			if(_bubblableActs!=value){
				var act:IBubblableAct;
				if(_bubblableActs){
					for each(act in _bubblableActs){
						_removeBubblableAct(act);
					}
				}
				_bubblableActs = value;
				if(_bubblableActs){
					for each(act in _bubblableActs){
						_addBubblableAct(act);
					}
				}
			}
		}
		
		protected var _onBubbled:Act;
		private var _bubblableActs:Array;
		private var _proxiedActs:Dictionary;
		private var _childHubs:Dictionary;
		
		public function BubbleHub(bubblableActs:Array=null){
			this.bubblableActs = bubblableActs;
		}
		
		public function addChildHub(bubbleHub:IBubbleHub):void{
			if(!_childHubs)_childHubs = new Dictionary();
			if(!_childHubs[bubbleHub]){
				_childHubs[bubbleHub] = true;
				bubbleHub.onBubbled.addHandler(handleBubbledAct);
			}
		}
		public function removeChildHub(bubbleHub:IBubbleHub):void{
			if(_childHubs){
				if(_childHubs[bubbleHub]){
					delete _childHubs[bubbleHub];
					bubbleHub.onBubbled.removeHandler(handleBubbledAct);
				}
			}
		}
		
		public function addHandler(bubbleId:String, handler:Function, additionalParameters:Array):void{
			if(!_proxiedActs){
				_proxiedActs = new Dictionary();
			}
			var proxyAct:Act = _proxiedActs[bubbleId];
			if(!proxyAct){
				proxyAct = new Act();
				_proxiedActs[bubbleId] = proxyAct;
			}
			proxyAct.addHandler(handler,additionalParameters);
		}
		
		public function removeHandler(bubbleId:String, handler:Function):void{
			if(_proxiedActs){
				_proxiedActs = new Dictionary();
				var proxyAct:Act = _proxiedActs[bubbleId];
				if(proxyAct){
					proxyAct.removeHandler(handler);
					if(!proxyAct.handlerCount){
						proxyAct.release();
						delete _proxiedActs[bubbleId];
					}
				}
			}
		}
		
		public function addBubblableAct(bubblableAct:IBubblableAct):void{
			if(!_bubblableActs)_bubblableActs = [];
			if(_bubblableActs.indexOf(bubblableAct)==-1){
				_addBubblableAct(bubblableAct);
			}
		}
		protected function _addBubblableAct(bubblableAct:IBubblableAct):void{
			bubblableAct.addHandler(handleDirectAct,[bubblableAct]);
		}
		public function removeBubblableAct(bubblableAct:IBubblableAct):void{
			if(_bubblableActs){
				var index:int = _bubblableActs.indexOf(bubblableAct);
				_removeBubblableAct(bubblableAct);
				_bubblableActs.splice(index,1);
			}
		}
		protected function _removeBubblableAct(bubblableAct:IBubblableAct):void{
			bubblableAct.removeHandler(handleDirectAct);
		}
		
		protected function handleDirectAct(... params):void{
			var act:IBubblableAct = params.pop();
			callHandlers(act.bubbleId,params);
			if(act.shouldBubble && _onBubbled){
				_onBubbled.perform(act,params);
			}
		}
		protected function handleBubbledAct(act:IBubblableAct, params:Array):void{
			callHandlers(act.bubbleId,params);
			if(_onBubbled){
				_onBubbled.perform(act,params);
			}
		}
		protected function callHandlers(bubbleId:String, params:Array):void{
			if(_proxiedActs){
				var proxyAct:Act = _proxiedActs[bubbleId];
				if(proxyAct)proxyAct.perform.apply(null,params);
			}
		}
	}
}