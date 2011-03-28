package org.tbyrne.binding
{
	import flash.utils.Dictionary;

	public class Binder
	{
		private static var _srcPropLookup:Dictionary;
		private static var _destPropLookup:Dictionary;
		
		public static function bind(destObject:Object, destProp:String, srcBindable:Object, srcProp:String):void{
			
			var srcObjectLookup:Dictionary;
			var destObjectLookup:Dictionary;
			if(!_srcPropLookup){
				_srcPropLookup = new Dictionary();
				_destPropLookup = new Dictionary();
			}else{
				srcObjectLookup = _srcPropLookup[srcProp];
				destObjectLookup = _destPropLookup[destProp];
			}
			
			var binder:Binder;
			if(!srcObjectLookup){
				srcObjectLookup = new Dictionary();
				_srcPropLookup[srcProp] = srcObjectLookup;
			}else{
				binder = srcObjectLookup[srcBindable];
			}
			
			if(!destObjectLookup){
				destObjectLookup = new Dictionary();
				_destPropLookup[destProp] = destObjectLookup;
			}else{
				var oldBinder:Binder = destObjectLookup[destObject];
				if(oldBinder){
					oldBinder.removeDestination(destObject,destProp);
					if(!oldBinder.destinationCount){
						var oldSrcObjectLookup:Dictionary = _srcPropLookup[oldBinder.srcProp];
						delete oldSrcObjectLookup[oldBinder.srcBindable];
					}
				}
			}
			
			if(binder){
				binder.addDestination(destObject,destProp);
			}else{
				binder = new Binder(destObject,destProp,srcBindable,srcProp);
				srcObjectLookup[srcBindable] = binder;
			}
			destObjectLookup[destObject] = binder;
		}
		public static function unbind(destObject:Object, destProp:String):void{
			if(_destPropLookup){
				var destObjectLookup:Dictionary = _destPropLookup[destProp];
				if(destObjectLookup){
					var binder:Binder = destObjectLookup[destObject];
					if(binder){
						binder.removeDestination(destObject,destProp);
						delete destObjectLookup[destObject];
						if(!binder.destinationCount){
							var srcObjectLookup:Dictionary = _srcPropLookup[binder.srcProp];
							delete srcObjectLookup[binder.srcBindable];
						}
					}
				}
			}
		}
		
		
		public function get srcBindable():Object{
			return _propWatcher.bindable;
		}
		public function set srcBindable(value:Object):void{
			_propWatcher.bindable = value;
		}
		public function get srcProp():String{
			return _propWatcher.property;
		}
		public function set srcProp(value:String):void{
			_propWatcher.property = value;
		}
		public function get destinationCount():int{
			return _destinationCount;
		}
		
		
		public var doUnset:Boolean = true;
		
		
		private var _propWatcher:PropertyWatcher;
		private var _value:*;
		private var _numberMode:Boolean;
		private var _destinations:Dictionary = new Dictionary();
		private var _destinationCount:int = 0;
		
		public function Binder(destObject:Object=null, destProp:String=null, srcBindable:Object=null, srcProp:String=null){
			_propWatcher = new PropertyWatcher(srcProp,setValue,null,null,srcBindable);
			if(destObject && destProp){
				addDestination(destObject,destProp);
			}
		}
		public function addDestination(destObject:Object, destProp:String):void{
			var destLookup:Dictionary = _destinations[destProp];
			if(!destLookup){
				destLookup = new Dictionary();
				_destinations[destProp] = destLookup;
			}else if(destLookup[destObject]){
				//already added
				return;
			}
			destLookup[destObject] = true;
			setDestValueIn(_value,destObject,destProp);
			++_destinationCount;
		}
		public function removeDestination(destObject:Object, destProp:String):void{
			var destLookup:Dictionary = _destinations[destProp];
			if(destLookup && destLookup[destObject]){
				delete destLookup[destObject];
				if(doUnset){
					setDestValueIn(_numberMode?NaN:null,destObject,destProp);
				}
				--_destinationCount;
			}
		}
		
		protected function setValue(value:*):void{
			_value = value;
			_numberMode = (value is Number);
			setDestValue(_value);
		}
		protected function setDestValue(value:*):void{
			for(var prop:String in _destinations){
				var destLookup:Dictionary = _destinations[prop];
				for(var obj:* in destLookup){
					setDestValueIn(value,obj,prop);
				}
			}
		}
		protected function setDestValueIn(value:*, destObject:Object, destProp:String):void{
			var subject:Object = destObject;
			var propPath:Array = destProp.split(".");
			var propCount:int = propPath.length;
			for(var i:int=0; i<propCount-2; i++){
				subject = subject[propPath[i]];
			}
			subject[propPath[propCount-1]] = value;
		}
	}
}