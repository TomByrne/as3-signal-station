package org.tbyrne.core
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.tbyrne.memory.LooseReference;
	import org.tbyrne.memory.ObjectLocker;
	
	public class DelayedCall
	{
		private static var FRAME_DISPATCHER:Shape = new Shape();
		
		
		public function get remainingRepeat():uint{
			return _executions-_executed;
		}
		public function get currentRepeat():uint{
			return _executed;
		}
		public function get remainingDelay():Number{
			if(_running){
				if(seconds){
					return _startDelay-_timer.currentCount;
				}else{
					return _startDelay-_frameCount;
				}
			}else{
				return _startDelay;
			}
		}
		public function get currentCount():Number{
			if(seconds){
				return _timer.currentCount;
			}else{
				return _frameCount;
			}
		}
		public function get startDelay():Number{
			return _startDelay;
		}
		public function set startDelay(value:Number):void{
			if(_startDelay != value){
				if(_running){
					_begin(remainingDelay-(_startDelay-value));
				}
				_startDelay = value;
			}
		}
		public function get callFunction():Function{
			return _strongReference;
		}
		public function set callFunction(value:Function):void{
			if(value != null){
				_strongReference = value;
				if(!_looseReference){
					_looseReference = LooseReference.getNew();
				}
				_looseReference.object = value;
			}else{
				Log.error( "DelayedCall.callFunction: DelayedCall.callFunction must be non-null");
			}
		}
		public function get seconds():Boolean{
			return _seconds;
		}
		public function set seconds(value:Boolean):void{
			if(_seconds!=value){
				var remaining:Number = remainingDelay;
				_seconds = value;
				if(_running)_begin(remaining);
			}
		}
		
		public function get parameters():Array{
			return _parameters;
		}
		public function set parameters(value:Array):void{
			_parameters = value;
		}
		public function get executions():uint{
			return _executions;
		}
		public function set executions(value:uint):void{
			if(_executions != value){
				if(_running && value<_executed && value!=0){
					clear();
				}
				if(_executions!=0 && value==0){
					ObjectLocker.unlock(this);
				}else if(_executions==0 && value!=0){
					ObjectLocker.lock(this);
				}
				_executions = value;
			}
		}
		
		public function get running():Boolean{
			return _running;
		}
		protected function setRunning(value: Boolean): void
		{
			this._running = value;
			this.updateFuncReference();
		}
		
		public function set locked(value: Boolean): void
		{
			this._locked = value;
			this.updateFuncReference();
		}
		public function get locked(): Boolean
		{
			return this._locked;
		}
		
		public function get delay(): Number
		{
			return this._delay;
		}
		
		private var _running:Boolean;
		private var _listening:Boolean = false;
		private var _strongReference:Function;
		private var _looseReference:LooseReference;
		private var _startDelay:Number;
		private var _delay: Number;
		private var _seconds:Boolean = true;
		private var _parameters:Array;
		private var _executions: uint;
		private var _locked: Boolean;
		
		private var _executed:uint;
		private var _frameCount:int;
		private var _timer:Timer;
		
		public function DelayedCall(callFunction:Function, delay:Number, seconds:Boolean = true, 
			parameters:Array=null, executions:uint = 1)
		{
			this._executions = 0;
			this._locked = true;
			this._running = false;
			
			this._delay = delay;
			
			this.callFunction = callFunction;
			this.startDelay = this.delay;
			this.seconds = seconds;
			this.parameters = parameters;
			this.executions = executions;
		}
		public function begin():void{
			if(!this._looseReference.referenceExists) {
				Log.error( "DelayedCall.begin: function reference has been lost");
			}
			if(_startDelay==0 && this.executions==0){
				Log.error( "DelayedCall.begin: cannot have 0 delay and infinite repeat");
			}
			this.setRunning(true);
			_executed = 0;
			_begin(_startDelay);
		}
		protected function _begin(delay:Number):void{
			if(_listening)stopListening();
			_listening = true;
			if(delay>0){
				if(seconds){
					_timer = new Timer(delay*1000, 1);
					_timer.addEventListener(TimerEvent.TIMER,executeCall,false,0,true);
					_timer.start();
				}else {
					FRAME_DISPATCHER.addEventListener(Event.ENTER_FRAME,frameTick,false,0,true);
					_frameCount = 0;
				}
			}else{
				executeCall();
			}
		}
		
		public function clear():void{
			this.setRunning(false);
			stopListening();
		}
		
		private function updateFuncReference(): void
		{
			this._looseReference.locked = (this.locked || this.running);
		}
		
		protected function stopListening():void{
			if(_listening){
				_listening = false;
				if(_startDelay){
					if(seconds){
						_timer.removeEventListener(TimerEvent.TIMER,executeCall);
						_timer = null;
					}else{
						FRAME_DISPATCHER.removeEventListener(Event.ENTER_FRAME,frameTick);
						_frameCount = 0;
					}
				}
			}
		}
		private function frameTick(e:Event = null):void{
			_frameCount++;
			if(_frameCount>=_startDelay)executeCall();
		}
		private function executeCall(e:Event = null):void{
			_executed++;
			var func:Function = this._looseReference.reference as Function;
			if(this.executions!=0 && _executed>=this.executions){
				clear();
				ObjectLocker.unlock(this);
			}else{
				_begin(_startDelay);
			}
			func.apply(null,parameters);
		}
	}
}