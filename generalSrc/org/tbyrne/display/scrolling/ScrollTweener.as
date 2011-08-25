package org.tbyrne.display.scrolling
{
	import caurina.transitions.Equations;
	import caurina.transitions.Tweener;
	
	public class ScrollTweener extends ScrollProxy
	{
		override public function set target(value:IScrollMetrics):void{
			if(_target!=value){
				Tweener.removeTweens(_tweenTarget);
				if(_target){
					_target.scrollMetricsChanged.removeHandler(onInnerScrollMetricsChanged);
				}
				_target = value;
				if(_target){
					_target.scrollMetricsChanged.addHandler(onInnerScrollMetricsChanged);
					_scrollValue = _target.scrollValue;
				}
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		
		private var _scrollValue:Number = 0;
		private var _tweenTarget:TweenTarget;
		private var _ignoreChanges:Boolean;
		
		public function ScrollTweener(target:IScrollMetrics=null){
			_tweenTarget = new TweenTarget();
			super(target);
		}
		override public function get scrollValue():Number{
			return _scrollValue;
		}
		override public function set scrollValue(value:Number):void{
			if(_scrollValue!=value){
				_tweenTarget.value = _scrollValue;
				_scrollValue = value;
				if(_target)Tweener.addTween(_tweenTarget,{value:value, transition:Equations.easeOutExpo, time:0.5, onUpdate:onTweenChange});
				if(_scrollMetricsChanged)_scrollMetricsChanged.perform(this);
			}
		}
		
		protected function onTweenChange():void{
			_ignoreChanges = true;
			_target.scrollValue = _tweenTarget.value;
			_ignoreChanges = false;
		}
		
		override protected function onInnerScrollMetricsChanged(from:IScrollMetrics):void{
			if(_ignoreChanges)return;
			
			_scrollValue = _target.scrollValue;
			Tweener.removeTweens(_tweenTarget);
			super.onInnerScrollMetricsChanged(from);
		}
	}
}
class TweenTarget{
	public var value:Number;
}