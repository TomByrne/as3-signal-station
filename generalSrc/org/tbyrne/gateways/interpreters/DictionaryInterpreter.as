package org.tbyrne.gateways.interpreters
{
	import flash.utils.Dictionary;
	
	public class DictionaryInterpreter implements IDataInterpreter
	{
		public var specificInterpreters:Dictionary = new Dictionary();
		public var nestedInterpreters:Vector.<IDataInterpreter>;
		
		public function DictionaryInterpreter(nestedInterpreters:*=null){
			var vectCast:Vector.<IDataInterpreter> = (nestedInterpreters as Vector.<IDataInterpreter>);
			var arrCast:Array;
			var dataCast:IDataInterpreter;
			if(vectCast){
				this.nestedInterpreters = vectCast;
			}else if(arrCast = (nestedInterpreters as Array)){
				this.nestedInterpreters = Vector.<IDataInterpreter>(arrCast);
			}else if(dataCast = (nestedInterpreters as IDataInterpreter)){
				this.nestedInterpreters = Vector.<IDataInterpreter>([dataCast]);
			}
		}
		
		public function incoming(data:*):*{
			var cast:Object = (data as Object);
			if(cast){
				var ret:Dictionary = new Dictionary();
				for(var i:* in cast){
					var value:* = cast[i];
					if(value!=null){
						var datInt:IDataInterpreter = specificInterpreters[i];
						if(datInt){
							value = datInt.incoming(value);
						}else{
							for each(datInt in nestedInterpreters){
								value = datInt.incoming(value);
							}
						}
					}
					ret[i] = value
				}
				return ret;
			}else{
				return data;
			}
		}
		
		public function outgoing(data:*):*{
			var cast:Dictionary = (data as Dictionary);
			if(cast){
				var ret:Dictionary = new Dictionary();
				for(var i:* in cast){
					var value:* = cast[i];
					if(value!=null){
						var datInt:IDataInterpreter = specificInterpreters[i];
						if(datInt){
							value = datInt.outgoing(value);
						}else{
							for each(datInt in nestedInterpreters){
								value = datInt.outgoing(value);
							}
						}
					}
					ret[i] = value
				}
				return ret;
			}else{
				return data;
			}
		}
		
		public function addSpecificInterpreter(propKey:*, interpreter:IDataInterpreter):void{
			specificInterpreters[propKey] = interpreter;
		}
		public function removeSpecificInterpreter(propKey:*):void{
			delete specificInterpreters[propKey];
		}
	}
}