package org.farmcode.actLibrary.display.progress
{
	import flash.utils.Dictionary;
	
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.display.popup.acts.AddPopupAct;
	import org.farmcode.actLibrary.display.popup.acts.RemovePopupAct;
	import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.phases.LogicPhases;
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.popup.PopupInfo;
	import org.farmcode.display.progress.IProgressDisplay;
	
	use namespace ActingNamspace;

	public class ProgressIndicatorActor extends UniversalActorHelper
	{
		public function get progressDisplay():IProgressDisplay{
			return _progressDisplay;
		}
		public function set progressDisplay(value:IProgressDisplay):void{
			if(value!=_progressDisplay){
				var wasShown:Boolean = _shown;
				shown = false;
				_progressDisplay = value;
				if(value){
					_popupInfo.popupDisplay = value.display;
				}else{
					_popupInfo.popupDisplay = null;
				}
				if(wasShown){
					checkProgress();
					shown = true;
				}
			}
		}
		public function get focusActs():Array{
			return _popupInfo.focusActs;
		}
		public function set focusActs(value:Array):void{
			_popupInfo.focusActs = value;
		}
		protected function get shown():Boolean{
			return _shown;
		}
		protected function set shown(value:Boolean):void{
			if(_shown!=value){
				_shown = value;
				if(_progressDisplay){
					if(_shown){
						_openPopupAct.perform(_currentProgressBundle.execution);
						_delayedCall.begin();
					}else{
						_delayedCall.clear();
						_closePopupAct.perform();
					}
				}
			}
		}
		
		/**
		 * Whether the percentage should indicate the immediate task (whose message is being shown)
		 * or all tasks in this progress tree.
		 */
		public var showTotal:Boolean = true;
		
		private var _shown:Boolean = false;
		private var _progressDisplay:IProgressDisplay;
		private var _delayedCall:DelayedCall = new DelayedCall(checkProgress,1,false,null,0);
		
		private var _executionMap:Dictionary = new Dictionary();
		private var _currentProgressBundle:ProgressExecutionBundle; // top level execution
		private var _topLevelBundles:Array = [];
		
		private var _openPopupAct:AddPopupAct;
		private var _closePopupAct:RemovePopupAct;
		private var _popupInfo:PopupInfo;
		
		public function ProgressIndicatorActor(){
			_openPopupAct = new AddPopupAct(_popupInfo);
			addChild(_openPopupAct);
			
			_closePopupAct = new RemovePopupAct(_popupInfo);
			addChild(_closePopupAct);
			
			metadataTarget = this;
		}
		
		protected function assessBundle():void{
			var newBundle:ProgressExecutionBundle = _topLevelBundles[0];
			if(newBundle!=_currentProgressBundle){
				_currentProgressBundle = newBundle;
				if(_currentProgressBundle){
					checkProgress();
					shown = true;
				}else{
					shown = false;
				}
			}
		}
		protected function checkProgress():void{
			if (_progressDisplay){
				_currentProgressBundle.fillDisplay(_progressDisplay,showTotal);
			}
		}
		
		public var beforeProcessBefore:Array = [LogicPhases.PROCESS_COMMAND];
		[ActRule(ActClassRule,beforePhases="{beforeProcessBefore}")]
		public function beforeProcess(execution:UniversalActExecution, cause:IExecutionProgressAct):void{
			if(!_executionMap[execution]){
				var bundle:ProgressExecutionBundle = ProgressExecutionBundle.getNew(cause,execution);
				_executionMap[execution] = bundle
				
				var parent:UniversalActExecution = execution.parentExecution;
				var foundParent:Boolean;
				while(parent){
					var parentBundle:ProgressExecutionBundle = _executionMap[parent];
					if(parentBundle){
						foundParent = true;
						parentBundle.currentChildBundle = bundle;
						break;
					}
					parent = parent.parentExecution;
				}
				if(!foundParent){
					_topLevelBundles.push(bundle);
					if(!_currentProgressBundle)assessBundle();
				}
			}
			execution.continueExecution();
		}
		public var afterProcessAfter:Array = [LogicPhases.PROCESS_COMMAND];
		[ActRule(ActClassRule,beforePhases="{afterProcessAfter}")]
		public function afterProcess(execution:UniversalActExecution, cause:IExecutionProgressAct):void{
			var bundle:ProgressExecutionBundle = _executionMap[execution];
			if(bundle){
				var topIndex:int = _topLevelBundles.indexOf(bundle);
				if(topIndex!=-1){
					_topLevelBundles.splice(topIndex, 1);
				}else{
					var parent:UniversalActExecution = execution.parentExecution;
					while(parent){
						var parentBundle:ProgressExecutionBundle = _executionMap[parent];
						if(parentBundle){
							parentBundle.currentChildBundle = bundle.currentChildBundle;
							break;
						}
						parent = parent.parentExecution;
					}
				}
				bundle.release();
				delete _executionMap[execution];
				if(bundle==_currentProgressBundle)assessBundle();
			}
			execution.continueExecution();
		}
	}
}
import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
import org.farmcode.actLibrary.display.progress.actTypes.IProgressAct;
import org.farmcode.acting.ActingNamspace;
import org.farmcode.acting.universal.UniversalActExecution;
import org.farmcode.display.progress.IProgressDisplay;

use namespace ActingNamspace;
	
class ProgressExecutionBundle{
	private static var pool:Array = new Array();
	
	public static function getNew(act:IExecutionProgressAct, execution:UniversalActExecution):ProgressExecutionBundle{
		if(pool.length){
			var ret:ProgressExecutionBundle = pool.shift();
			ret.init(act, execution);
			return ret;
		}else{
			return new ProgressExecutionBundle(act, execution);
		}
	}
	
	private static const DEFAULT_MESSAGE:String = "LOADING";
	
	public function get message():String{
		return _act.message?_act.message:DEFAULT_MESSAGE;
	}
	public function get measurable():Boolean{
		if(_progAct){
			return _progAct.measurable;
		}else{
			return (total>0);
		}
	}
	public function get units():String{
		if(_progAct){
			return _progAct.units;
		}else{
			return null;
		}
	}
	public function get total():Number{
		if(_progAct){
			return _progAct.total;
		}else{
			return _total;
		}
	}
	public function get progress():Number{
		if(_progAct){
			return _progAct.progress;
		}else{
			if(_currentChildBundle){
				return _complete+(_currentChildBundle.progress/_currentChildBundle.total);
			}else{
				return _complete;
			}
		}
	}
	
	public function get act():IExecutionProgressAct{
		return _act;
	}
	public function get progAct():IProgressAct{
		return _progAct;
	}
	public function get execution():UniversalActExecution{
		return _execution;
	}
	
	public var currentChildBundle:ProgressExecutionBundle;
	
	
	private var _act:IExecutionProgressAct;
	private var _progAct:IProgressAct;
	private var _execution:UniversalActExecution;
	private var _generation:int;
	private var _currentChildBundle:ProgressExecutionBundle;
	
	private var _total:Number;
	private var _complete:Number;
	
	public function ProgressExecutionBundle(act:IExecutionProgressAct, execution:UniversalActExecution){
		init(act, execution);
	}
	public function init(act:IExecutionProgressAct, execution:UniversalActExecution):void{
		_act = act;
		_progAct = (act as IProgressAct);
		_execution = execution;
		
		_complete = _execution.index;
		_total = _execution.reactionCount;
		_execution.indexChanged.addHandler(onIndexChanged);
		_execution.reactionCountChanged.addHandler(onTotalChanged);
	}
	public function onIndexChanged(from:UniversalActExecution):void{
		_complete = _execution.index;
	}
	public function onTotalChanged(from:UniversalActExecution):void{
		_total = _execution.reactionCount;
	}
	public function release():void{
		_execution.indexChanged.removeHandler(onIndexChanged);
		_execution.reactionCountChanged.removeHandler(onTotalChanged);
		_execution = null;
		
		_act = null;
		_progAct = null;
		pool.push(this);
	}
	public function fillDisplay(display:IProgressDisplay, showTotal:Boolean):void{
		var progBundle:ProgressExecutionBundle;
		var messageBundle:ProgressExecutionBundle = getLowestBundle();
		if(showTotal){
			progBundle = this;
		}else{
			progBundle = messageBundle;
		}
		
		display.message = messageBundle.message;
		display.measurable = progBundle.measurable;
		display.units = progBundle.units;
		display.total = progBundle.total;
		display.progress = progBundle.progress;
	}
	public function getLowestBundle():ProgressExecutionBundle{
		if(!_currentChildBundle){
			return this;
		}else{
			return _currentChildBundle.getLowestBundle();
		}
	}
}