package org.farmcode.sodalityLibrary.control
{
	import org.farmcode.sodalityLibrary.control.members.IDestinationMember;
	import org.farmcode.sodalityLibrary.control.members.ISourceMember;
	import org.farmcode.sodalityLibrary.control.modifiers.IValueModifier;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.farmcode.core.DelayedCall;
		
	public class ControlBinding{
		private var sourceProperty:ISourceMember;
		private var destProperty:IDestinationMember;
		private var modifiers:Array;
		private var cancelled:Boolean = false;
		private var readyForExecute:Boolean = true;
		private var frameRateLimit:Boolean = false;
		private var valid:Boolean = false;
		
		private var frameLimiter:DelayedCall = new DelayedCall(changeReady,1,false);
		
		public function ControlBinding(sourceProperty:ISourceMember, destProperty:IDestinationMember, modifiers:Array=null, frameRateLimit:Boolean=false){
			this.sourceProperty = sourceProperty;
			this.destProperty = destProperty;
			this.modifiers = modifiers;
			this.frameRateLimit = frameRateLimit;
			sourceProperty.addEventListener(Event.CHANGE,validate);
			if(modifiers){
				for each(var modifier:IValueModifier in modifiers){
					if(!modifier.hasEventListener(Event.CHANGE))modifier.addEventListener(Event.CHANGE,validate);
				}
			}
		}
		
		private function validate(e:Event=null):void{
			if(readyForExecute){
				valid = true;
				readyForExecute = false;
				var value:* = sourceProperty?sourceProperty.value:null;
				if(modifiers){
					var destProp:* = destProperty?destProperty.value:null;
					cancelled = false;
					var length:int = modifiers.length;
					for(var i:int=0; i<length; ++i){
						var modifier:IValueModifier = modifiers[i];
						modifier.addEventListener(Event.CANCEL, onCancel);
						value = modifier.input(value,destProp);
						modifier.removeEventListener(Event.CANCEL, onCancel);
						if(cancelled){
							return;
						}
					}
				}
				if(destProperty){
					if((sourceProperty.value is Event) && (destProperty.value is EventDispatcher)){
						if(value){
							(destProperty.value as EventDispatcher).dispatchEvent(value as Event);
						}
					}else destProperty.value = value;
				}
				if(frameRateLimit){
					frameLimiter.begin();
				}else{
					readyForExecute = true;
				}
			}else{
				valid = false;
			}
		}
		private function changeReady():void{
			readyForExecute = true;
			if(!valid){
				validate();
			}
		}
		private function onCancel(e:Event):void{
			cancelled = true;
		}
		public function destroy():void{
			for each(var modifier:IValueModifier in modifiers){
				modifier.removeEventListener(Event.CHANGE,validate);
			}
			modifiers = null;
			sourceProperty.removeEventListener(Event.CHANGE,validate);
			sourceProperty = null;
			destProperty = null;
		}
	}
}