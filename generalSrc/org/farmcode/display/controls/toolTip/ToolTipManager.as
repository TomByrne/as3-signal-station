package org.farmcode.display.controls.toolTip
{
	
	import flash.geom.Rectangle;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IStageAsset;
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.controls.popout.PopoutDisplay;
	import org.farmcode.display.core.ILayoutView;
	
	use namespace DisplayNamespace;
	
	public class ToolTipManager implements IToolTipManager
	{
		/**
		 * This determines the priority of Tool Tips, which in turn
		 * determines which will be visible when multiple are active.
		 */
		private var TYPE_ORDER:Array = [ToolTipTypes.DATA_ENTRY_TIP,ToolTipTypes.CONTEXTUAL_TIP,ToolTipTypes.DATA_ENTRY_ERROR];
		/**
		 * When multiple tips of the same type are active, this detmines
		 * how long each is shown (as they get cycled through).
		 */
		private var CYCLE_DURATION:Number = 1.2 // in seconds
		
		public function get tipTriggers():Array{
			return _tipTriggers;
		}
		public function set tipTriggers(value:Array):void{
			if(_tipTriggers!=value){
				var trigger:IToolTipTrigger;
				if(_tipTriggers){
					for each(trigger in _tipTriggers){
						trigger.activeChanged.removeHandler(onActiveChanged);
					}
				}
				_tipTriggers = value;
				_activeTriggers = [];
				if(_tipTriggers){
					for each(trigger in _tipTriggers){
						trigger.activeChanged.addHandler(onActiveChanged);
						if(trigger.active){
							_activeTriggers.push(trigger);
						}
					}
					setActive();
				}
			}
		}
		public function get stage():IStageAsset{
			return _popoutDisplay.stage;
		}
		public function set stage(value:IStageAsset):void{
			_popoutDisplay.stage = value;
		}
		
		
		public function get toolTipDisplay():IToolTipDisplay{
			return _toolTipDisplay;
		}
		public function set toolTipDisplay(value:IToolTipDisplay):void{
			if(_toolTipDisplay!=value){
				if(_toolTipDisplay){
					_popoutDisplay.popout = null;
					_toolTipDisplay.measurementsChanged.removeHandler(onDisplayMeasChanged);
					value.anchorView = null;
				}
				_toolTipDisplay = value;
				if(_toolTipDisplay){
					_popoutDisplay.popout = _toolTipDisplay;
					_toolTipDisplay.measurementsChanged.addHandler(onDisplayMeasChanged);
					value.data = _data;
					value.anchor = _anchor;
					value.anchorView = _anchorView;
					setPosition();
				}
			}
		}
		
		private var _tipTriggers:Array;
		private var _activeTriggers:Array;
		private var _currentlyActiveList:Array;
		private var _currentlyActiveType:String;
		private var _currentlyShown:IToolTipTrigger;
		
		private var _data:*;
		private var _anchor:String;
		private var _anchorView:ILayoutView;
		
		private var _toolTipDisplay:IToolTipDisplay;
		private var _popoutDisplay:PopoutDisplay = new PopoutDisplay();
		
		private var _cycleCall:DelayedCall = new DelayedCall(doCycle,CYCLE_DURATION,true,null,0);
		
		public function ToolTipManager(){
			super();
			_popoutDisplay.popoutLayoutInfo.keepWithinStageBounds = true;
		}
		public function addTipTrigger(trigger:IToolTipTrigger):void{
			if(!_tipTriggers)_tipTriggers = [];
			_tipTriggers.push(trigger);
			
			trigger.activeChanged.addHandler(onActiveChanged);
			if(trigger.active){
				if(!_activeTriggers)_activeTriggers = [];
				_activeTriggers.push(trigger);
				setActive();
			}
		}
		public function removeTipTrigger(trigger:IToolTipTrigger):void{
			var index:int = _tipTriggers.indexOf(trigger);
			_tipTriggers.splice(index,1);
			
			trigger.activeChanged.removeHandler(onActiveChanged);
			if(trigger.active){
				index = _activeTriggers.indexOf(trigger);
				_activeTriggers.splice(index,1);
			}
		}
		protected function onDisplayMeasChanged(from:ILayoutView, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			setPosition();
		}
		protected function onPositionChanged(from:ILayoutView, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number):void{
			setPosition();
		}
		protected function setPosition() : void{
			if(_anchorView && _popoutDisplay.popout){
				var anchorPos:Rectangle = _anchorView.displayPosition;
				var displayMeas:Rectangle = _popoutDisplay.popout.displayMeasurements;
				if(displayMeas){
					switch(_anchor){
						case Anchor.LEFT:
						case Anchor.TOP_LEFT:
						case Anchor.BOTTOM_LEFT:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetX = -displayMeas.width;
							break;
						case Anchor.RIGHT:
						case Anchor.TOP_RIGHT:
						case Anchor.BOTTOM_RIGHT:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetX = anchorPos.width;
							break;
						default:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetX = (anchorPos.width-displayMeas.width)/2;
					}
					switch(_anchor){
						case Anchor.TOP:
						case Anchor.TOP_LEFT:
						case Anchor.TOP_RIGHT:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetY = -displayMeas.height;
							break;
						case Anchor.BOTTOM:
						case Anchor.BOTTOM_LEFT:
						case Anchor.BOTTOM_RIGHT:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetY = anchorPos.height;
							break;
						default:
							_popoutDisplay.popoutLayoutInfo.relativeOffsetY = (anchorPos.height-displayMeas.height)/2;
					}
				}
			}
		}
		
		protected function onActiveChanged(from:IToolTipTrigger):void{
			if(from.active){
				if(!_activeTriggers)_activeTriggers = [];
				_activeTriggers.unshift(from);
			}else if(_activeTriggers){
				var index:int = _activeTriggers.indexOf(from);
				_activeTriggers.splice(index,1);
			}
			setActive();
		}
		protected function setActive():void{
			var bestTypeInd:int = -1;
			var bestList:Array;
			var bestType:String;
			
			for each(var trigger:IToolTipTrigger in _activeTriggers){
				var type:String = trigger.tipType;
				var index:int = TYPE_ORDER.indexOf(type);
				if(bestTypeInd==index){
					if(!bestList)bestList = [];
					bestList.push(trigger);
				}else if(bestTypeInd==-1 || bestTypeInd>index){
					bestTypeInd = index;
					bestList = [trigger];
					bestType = type;
				}
			}
			_currentlyActiveList = bestList;
			if(_currentlyActiveList){
				if(_currentlyActiveType!=bestType){
					_currentlyActiveType = bestType;
					_toolTipDisplay.tipType = _currentlyActiveType;
					setCurrentlyShown(_currentlyActiveList[0]);
				}
				if(_currentlyActiveList.length>1){
					startCycle();
				}else{
					stopCycle();
				}
			}else{
				_currentlyActiveType = null;
				setCurrentlyShown(null);
				_toolTipDisplay.tipType = null;
				stopCycle();
			}
		}
		
		protected function setCurrentlyShown(value:IToolTipTrigger):void{
			if(_currentlyShown!=value){
				if(_currentlyShown){
					_currentlyShown.dataAnchorChanged.removeHandler(onDataAnchorChanged);
				}
				_currentlyShown = value;
				
				if(_currentlyShown){
					_currentlyShown.dataAnchorChanged.addHandler(onDataAnchorChanged);
				}
				checkDataAnchor();
			}
		}
		protected function startCycle():void{
			if(!_cycleCall.running){
				_cycleCall.begin();
			}
		}
		protected function stopCycle():void{
			if(_cycleCall.running){
				_cycleCall.clear();
			}
		}
		protected function doCycle():void{
			var currIndex:int = _currentlyActiveList.indexOf(_currentlyShown);
			if(currIndex==_currentlyActiveList.length-1){
				currIndex = 0;
			}else{
				++currIndex;
			}
			setCurrentlyShown(_currentlyActiveList[currIndex]);
		}
		protected function checkDataAnchor():void{
			var newAnchorView:ILayoutView;
			if(_currentlyShown){
				newAnchorView = _currentlyShown.anchorView;
				_data = _currentlyShown.data;
				_anchor = _currentlyShown.anchor;
				
				_toolTipDisplay.data = _data;
				_toolTipDisplay.anchor = _anchor;
			}else{
				_toolTipDisplay.data = null;
				_toolTipDisplay.anchor = null;
			}
			if(newAnchorView!=_anchorView){
				if(_anchorView){
					_anchorView.positionChanged.removeHandler(onPositionChanged);
					_anchorView.assetChanged.removeHandler(onAnchorAssetChanged);
				}
				_anchorView = newAnchorView;
				_toolTipDisplay.anchorView = _anchorView;
				if(_anchorView){
					_anchorView.positionChanged.addHandler(onPositionChanged);
					_anchorView.assetChanged.addHandler(onAnchorAssetChanged);
				}
				checkAsset();
			}
			setPosition();
		}
		protected function checkAsset():void{
			if(_anchorView && _anchorView.asset){
				_popoutDisplay.relativeTo = _anchorView.asset;
				_popoutDisplay.popoutShown = true;
			}else{
				_popoutDisplay.popoutShown = false;
				_popoutDisplay.relativeTo = null;
			}
		}
		protected function onAnchorAssetChanged(from:ILayoutView, oldAsset:IDisplayAsset):void{
			checkAsset();
		}
		protected function onDataAnchorChanged(from:IToolTipTrigger):void{
			checkDataAnchor();
		}
	}
}