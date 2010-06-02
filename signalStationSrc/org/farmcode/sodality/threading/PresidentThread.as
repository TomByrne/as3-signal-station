package org.farmcode.sodality.threading
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.threading.AbstractThread;
	use namespace SodalityNamespace;
			
	public class PresidentThread extends AbstractThread
	{
		protected static const listeners:Dictionary = new Dictionary();
		protected static const typeMapping:Dictionary = new Dictionary();
		
		public static function addTypeMapping(adviceType:Class, threadId:String):void{
			typeMapping[adviceType] = new TypeMap(adviceType, threadId);
		}
		public static function removeTypeMapping(adviceType:Class):void{
			typeMapping[adviceType] = null;
			delete typeMapping[adviceType]
		}
		internal static function getTypeMapping(advice:IAdvice):String{
			for each(var typeMap:TypeMap in typeMapping){
				if(advice is typeMap.type){
					return typeMap.threadId;
				}
			}
			return null;
		}
		
		protected static function addInstance(thread:PresidentThread, president:President):void{
			var listener:PresidentListener = listeners[president];
			if(!listener)listener = listeners[president] = new PresidentListener(president);
			listener.addThread(thread);
		}
		protected static function removeInstance(thread:PresidentThread, president:President):void{
			var listener:PresidentListener = listeners[president];
			listener.removeThread(thread);
			if(listener.threadCount==0){
				listener.destroy();
				listeners[president] = null;
				delete listeners[president];
			}
		}
		
		public function get president():President{
			return _president;
		}
		public function set president(value:President):void{
			if(_president!=value){
				if(_president){
					removeInstance(this,_president);
				}
				_president = value;
				if(_president){
					addInstance(this,_president);
				}
			}
		}
		
		public var threadId:String;
		/**
		 * The discontinuous property indicates whether the thread should stop monitoring
		 * the enterFrame event when it has no advice left to execute. Set this to false when
		 * you are sure that there will be advice being fired on every frame for a slight
		 * performance boost.
		 */
		public var discontinuous:Boolean = true;
		private var _president:President;
		private var caughtAdvice:Array = [];
		
		public function PresidentThread(threadId:String = null, intendedThreadSpeed:Number=NaN, president:President=null, discontinuous:Boolean=true){
			super(intendedThreadSpeed);
			this.threadId = threadId;
			this.president = president;
			this.discontinuous = discontinuous;
		}
		
		internal function addPresidentEvent(e:PresidentEvent):void{
			caughtAdvice.push(e);
			beginProcessing();
		}
		override protected function process(... params):void{
			var beginTime:Number = getTimer();
			while(caughtAdvice.length){
				//trace("procSTART: " + getTimer());
				var event:PresidentEvent = caughtAdvice.shift();
				//var aStart: Number = getTimer();
				//var prevAdvice: IAdvice = event.adviceExecutionNode.advice;
				
				//trace("\t\tprocess: "+getTimer(),event.advice);
				event.continueExecution();
				
				/*trace("procEND: " + event.type + " " + (getTimer()-aStart) + "/" + (getTimer()-beginTime) + " (" + aStart + ") " + prevAdvice);
				if ((getTimer()-aStart) > 100 && !((prevAdvice is AsyncMethodAdvice) && ((prevAdvice as AsyncMethodAdvice).target is SiteStreamAdvisor)))
				{
					trace("  ESPECIALLY LONG");
				}*/
				if(!indefinate && getTimer()-beginTime>_processTime)break;
			}
			/*if(!caughtAdvice.length && discontinuous){
				endProcessing();
			}else{
				if(caughtAdvice.length)trace("------------------------------next frame: "+(getTimer()-beginTime),_processTime);
			}*/
		}
	}
}
class TypeMap{
	public var type:Class;
	public var threadId:String;
	
	public function TypeMap(type:Class, threadId:String){
		this.type = type;
		this.threadId = threadId;
	}
}