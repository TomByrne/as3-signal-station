package org.farmcode.sodalityLibrary.display.progress
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.farmcode.core.DelayedCall;
	import org.farmcode.display.progress.IProgressDisplay;
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.IPresidentAwareAdvisor;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodality.utils.AdviceExecutionNode;
	import org.farmcode.actLibrary.display.popup.acts.RemovePopupAct;
	import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
	import org.farmcode.sodalityPlatformEngine.display.popUp.advice.PlatformAddPopUpAdvice;
	
	use namespace SodalityNamespace;

	public class ProgressIndicatorAdvisor extends DynamicAdvisor implements IPresidentAwareAdvisor
	{
		public function get progressDisplay():IProgressDisplay{
			return _progressDisplay;
		}
		public function set progressDisplay(value:IProgressDisplay):void{
			if(value!=_progressDisplay){
				var wasShown:Boolean = _shown;
				shown = false;
				_progressDisplay = value;
				if(wasShown){
					checkAdvice();
					shown = true;
				}
			}
		}
		public function get focusAdvice():Array{
			return _focusAdvice;
		}
		public function set focusAdvice(value:Array):void{
			//if(value!=_focusAdvice){
				_focusAdvice = value;
			//}
		}
		/**
		 * Whether advice the percentage should indicate the immediate task (whose message is being shown)
		 * or all tasks in this progress tree.
		 */
		public function get showTotal():Boolean{
			return _showTotal;
		}
		public function set showTotal(value:Boolean):void{
			_showTotal = value;
		}
		public function set president(value:President):void{
			if(value!=_president){
				if(_president){
					_president.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
				_president = value;
				if(_president){
					_president.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
			}
		}
		protected function get shown():Boolean{
			return _shown;
		}
		protected function set shown(value:Boolean):void{
			if(_shown!=value){
				_shown = value;
				if(_progressDisplay){
					if(_shown){
						var popUpAdvice:PlatformAddPopUpAdvice = new PlatformAddPopUpAdvice();
						popUpAdvice.focusAdvice = _focusAdvice;
						popUpAdvice.display = _progressDisplay.display;
						popUpAdvice.executeBefore = _taskAtHand.node.advice;
						dispatchEvent(popUpAdvice);
						delayedCall.begin();
					}else{
						delayedCall.clear();
						var closePopUpAdvice:RemovePopupAct = new RemovePopupAct(null,_progressDisplay.display);
						dispatchEvent(closePopUpAdvice);
					}
				}
			}
		}
		
		private var _showTotal:Boolean = true;
		private var _shown:Boolean = false;
		private var _president:President;
		private var _progressDisplay:IProgressDisplay;
		private var delayedCall:DelayedCall = new DelayedCall(checkAdvice,1,false,null,0);
		private var progAdviceMap:Dictionary = new Dictionary();
		private var _focusAdvice:Array = [];
		public var allowMeasurable: Boolean;
		
		private var _taskAtHand:ProgressAdviceBundle; // the lowest level task being executed
		private var _treeAtHand:ProgressAdviceBundle; // it's top level task
		
		public function ProgressIndicatorAdvisor(){
			this.allowMeasurable = true;
		}
		
		protected function assessBestAdvice():void{
			var taskAtHand:ProgressAdviceBundle;
			var highestGeneration:Number;
			for each(var bundle:ProgressAdviceBundle in progAdviceMap){
				if(!taskAtHand || bundle.node.generation>highestGeneration){
					highestGeneration = bundle.node.generation;
					taskAtHand = bundle;
				}
			}
			setShownAdvice(taskAtHand);
		}
		protected function setShownAdvice(taskBundle:ProgressAdviceBundle):void{
			var treeBundle:ProgressAdviceBundle;
			if(taskBundle){
				var subject:AdviceExecutionNode = taskBundle.node;
				while(subject.parent){
					var bundle:ProgressAdviceBundle = progAdviceMap[subject];
					if(bundle){
						treeBundle = bundle;
					}
					subject = subject.parent;
				}
			}
			if(taskBundle!=_taskAtHand || treeBundle!=_treeAtHand){
				_taskAtHand = taskBundle;
				_treeAtHand = treeBundle;
				if(_taskAtHand && _taskAtHand.measurable){
					checkAdvice();
					shown = true;
				}else{
					shown = false;
				}
			}
		}
		protected function checkAdvice():void{
			if (_progressDisplay)
			{
				_progressDisplay.message = _taskAtHand.message;
				var progBundle:ProgressAdviceBundle = (_showTotal && _treeAtHand?_treeAtHand:_taskAtHand);
				if(progBundle.measurable && this.allowMeasurable){
					_progressDisplay.measurable = true;
					_progressDisplay.units = progBundle.units;
					_progressDisplay.total = progBundle.total;
					_progressDisplay.progress = progBundle.progress;
				}else{
					_progressDisplay.measurable = false;
					_progressDisplay.units = null;
					_progressDisplay.total = 
					_progressDisplay.progress = NaN;
				}
			}
		}
		protected function onAdviceExecute(e:PresidentEvent):void{
			var node:AdviceExecutionNode = e.adviceExecutionNode;
			while(node){
				addProgressNode(node);
				node = node.parent;
			}
		}
		protected function addProgressNode(node:AdviceExecutionNode):void{
			if(!progAdviceMap[node]){
				var cast:IExecutionProgressAct = (node.advice as IExecutionProgressAct);
				if(cast){
					var bundle:ProgressAdviceBundle = new ProgressAdviceBundle(cast,node);
					progAdviceMap[node] = bundle
					node.addEventListener(Event.COMPLETE, removeBundle);
					if(!_taskAtHand || _taskAtHand.node.generation<node.generation)setShownAdvice(bundle);
				}
			}
		}
		protected function removeBundle(e:Event):void{
			var node:AdviceExecutionNode = (e.target as AdviceExecutionNode);
			node.removeEventListener(Event.COMPLETE, removeBundle);
			var bundle:ProgressAdviceBundle = progAdviceMap[node];
			bundle.destroy();
			delete progAdviceMap[node];
			assessBestAdvice();
		}
	}
}
import org.farmcode.sodality.SodalityNamespace;
import org.farmcode.sodality.advice.IAdvice;
import org.farmcode.sodality.events.AdviceEvent;
import org.farmcode.sodality.events.PresidentEvent;
import org.farmcode.sodality.utils.AdviceExecutionNode;
import org.farmcode.actLibrary.display.progress.actTypes.IExecutionProgressAct;
import org.farmcode.actLibrary.display.progress.actTypes.IProgressAct;

use namespace SodalityNamespace;
	
class ProgressAdviceBundle{
	private static const DEFAULT_MESSAGE:String = "LOADING";
	
	public function get message():String{
		return advice.message?advice.message:DEFAULT_MESSAGE;
	}
	public function get measurable():Boolean{
		if(progAdvice){
			return progAdvice.measurable;
		}else{
			return (total>0);
		}
	}
	public function get units():String{
		if(progAdvice){
			return progAdvice.units;
		}else{
			return null;
		}
	}
	public function get total():Number{
		if(progAdvice){
			return progAdvice.total;
		}else{
			return _total;
		}
	}
	public function get progress():Number{
		if(progAdvice){
			return progAdvice.progress;
		}else{
			return _complete;
		}
	}
	public function get node():AdviceExecutionNode{
		return _node;
	}
	
	
	private var advice:IExecutionProgressAct;
	private var progAdvice:IProgressAct;
	private var _total:Number = 0;
	private var _complete:Number = 0;
	private var _node:AdviceExecutionNode;
	
	public function ProgressAdviceBundle(advice:IExecutionProgressAct, node:AdviceExecutionNode){
		this.advice = advice;
		this.progAdvice = (advice as IProgressAct);
		_node = node;
		node.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAddChild);
		searchNode(node);
	}
	protected function searchNode(node:AdviceExecutionNode):void{
		if(!node.complete)addChild(node.advice);
		var child:AdviceExecutionNode
		for each(child in node.executeAfter){
			searchNode(child);
		}
		for each(child in node.executeBefore){
			searchNode(child);
		}
	}
	public function onAddChild(e:PresidentEvent):void{
		addChild(e.advice);
	}
	protected function addChild(advice:IAdvice):void{
		_total++;
		advice.addEventListener(AdviceEvent.CONTINUE, onChildContinue,false,0,true);
	}
	public function destroy():void{
		_node.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAddChild);
		_total = _complete = 0;
		_node = null;
		progAdvice = null;
		advice = null;
	}
	protected function onChildContinue(e:AdviceEvent):void{
		_complete++;
	}
}