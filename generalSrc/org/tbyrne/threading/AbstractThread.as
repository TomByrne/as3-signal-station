package org.tbyrne.threading
{
	import flash.display.LoaderInfo;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.system.System;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;
	
	[Event(name="threadBegin",type="org.tbyrne.threading.ThreadEvent")]
	[Event(name="threadComplete",type="org.tbyrne.threading.ThreadEvent")]
	public class AbstractThread
	{
		{
			/*
				Static code block run when AbstractThread first referenced
				gets the stage's framerate.
			*/
			try{
				intendedFPS = LoaderInfo.getLoaderInfoByDefinition(AbstractThread).frameRate;
			}catch(e:Error){
				// If this SWF is not running in the localTrusted sandbox it will throw an error.
			}
		}
		
		
		private static var _intendedFPS:Number;
		protected static const instances:Array = [];
		protected static const FRAME_DISPATCHER:Shape = new Shape();
		
		
		public static function get numThreads(): uint{
			return AbstractThread.instances.length;
		}
		
		public static function get intendedFPS():Number{
			return _intendedFPS;
		}
		public static function set intendedFPS(value:Number):void{
			if(value !=_intendedFPS){
				_intendedFPS = value;
				for each(var thread:AbstractThread in instances){
					thread.evaluateProccessTime();
				}
			}
		}
		internal static function addThread(thread:AbstractThread):void{
			instances.push(thread);
		}
		internal static function removeThread(thread:AbstractThread):void{
			var index:int = instances.indexOf(thread);
			if(index!=-1){
				instances.splice(index,1);
			}
		}
		
		public function get processing():Boolean{
			return _processing;
		}
		public function get intendedThreadSpeed():Number{
			return _intendedThreadSpeed;
		}
		public function set intendedThreadSpeed(value:Number):void{
			//value = value>1?1:(value<0?0:value);
			if(value!=_intendedThreadSpeed){
				_intendedThreadSpeed = value;
				evaluateProccessTime();
			}
		}
		protected function get indefinate(): Boolean{
			return isNaN(_processTime);
		}
		
		
		/**
		 * handler(from:AbstractThread)
		 */
		public function get threadBegin():IAct{
			if(!_threadBegin)_threadBegin = new Act();
			return _threadBegin;
		}
		
		/**
		 * handler(from:AbstractThread)
		 */
		public function get threadEnd():IAct{
			if(!_threadEnd)_threadEnd = new Act();
			return _threadEnd;
		}
		
		protected var _threadEnd:Act;
		protected var _threadBegin:Act;
		
		
		protected var _processTime:Number; // the amount of time that this Thread is allowed to use per frame
		protected var _intendedThreadSpeed:Number; // between 0 - 1
		protected var _processing:Boolean;
		
		
		public function AbstractThread(intendedThreadSpeed:Number = 0.5){
			addThread(this);
			this.intendedThreadSpeed = intendedThreadSpeed;
		}
		public function destroy():void{
			endProcessing();
			removeThread(this);
		}
		protected function evaluateProccessTime():void{
			if(isNaN(intendedFPS)){
				Log.trace("WARNING: AbstractThread.evaluateProccessTime. intendedFPS is not set, thread will not limit processing.");
			}else{
				_processTime = (1000/intendedFPS)*_intendedThreadSpeed;
			}
		}
		protected function beginProcessing():void{
			if(!_processing){
				_processing = true;
				FRAME_DISPATCHER.addEventListener(Event.ENTER_FRAME,process);
				if(_threadEnd)_threadEnd.perform(this);
			}
		} 
		protected function endProcessing():void{
			if(_processing){
				_processing = false;
				FRAME_DISPATCHER.removeEventListener(Event.ENTER_FRAME,process);
				if(_threadBegin)_threadBegin.perform(this);
			}
		}
		
		protected function process(... params):void{
			// override this
		}
	}
}