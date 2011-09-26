package org.tbyrne.gateways.interpreters
{
	import flash.utils.Dictionary;

	/**
	 * The ObjectTyper class helps push loosely typed objects (from JSON
	 * normally) into strongly typed objects.
	 */
	public class ObjectTyper implements IDataInterpreter
	{
		
		public function get propMapping():Dictionary{
			return _propMapping;
		}
		public function set propMapping(value:Dictionary):void{
			_propMapping = value;
		}
		
		public function get type():Class{
			return _type;
		}
		public function set type(value:Class):void{
			_type = value;
		}
		public var doIncomingCheck:Boolean = true;
		
		private var _type:Class;
		private var _propMapping:Dictionary;
		private var _propLookup:Dictionary;
		private var _interpreters:Dictionary;
		private var _recursive:Boolean;
		
		
		public function ObjectTyper(type:Class=null, simplePropMapping:Object=null, recursive:Boolean=false, doIncomingCheck:Boolean=false){
			this.type = type;
			this._recursive = recursive;
			this.doIncomingCheck = doIncomingCheck;
			for(var i:String in simplePropMapping){
				addPropMapping(simplePropMapping[i],i);
			}
		}
		
		public function incoming(data:*):*{
			if(data!=null && typeof(data)=="object" && _type!=null){
				var objectData:Object = (data as Object);
				var propName:String;
				var matches:Boolean = true;
				if(doIncomingCheck){
					for(propName in objectData){
						if(!hasIncomingProp(propName)){
							matches = false;
							break;
						}
					}
				}
				if(matches){
					return doIncoming(data);
				}else if(_recursive && data.constructor==Object){
					for(var i:String in data){
						data[i] = incoming(data[i]);
					}
				}
			}
			return data;
		}
		protected function doIncoming(data:*):*{
			var ret:Object = new _type();
			for(var propName:String in _propMapping){
				var interpreters:Vector.<IDataInterpreter>;
				if(_interpreters){
					interpreters = _interpreters[propName];
				}
				interpretProp(ret,data,_propMapping[propName],propName,interpreters,true);
			}
			return ret;
		}
		//@TODO: optimise this out
		protected function hasIncomingProp(incomingProp:String):Boolean{
			for each(var i:String in _propMapping){
				if(i==incomingProp || i.indexOf(incomingProp+".")==0){
					return true;
				}
			}
			return false;
		}
		public function outgoing(data:*):*{
			if(data!=null){
				if(_type!=null && data is _type){
					return doOutgoing(data);
				}else if(_recursive && data.constructor==Object){
					for(var i:String in data){
						data[i] = outgoing(data[i]);
					}
				}
			}
			return data;
		}
		protected function doOutgoing(data:*):*{
			var propName:String;
			var ret:Object = {};
			for(propName in _propMapping){
				var interpreters:Vector.<IDataInterpreter>;
				if(_interpreters){
					interpreters = _interpreters[propName];
				}
				interpretProp(ret,data,propName,_propMapping[propName],interpreters,false);
			}
			return ret;
		}
		public function interpretProp(intoObj:Object, data:Object, propName:String, mappedTo:String, interpreters:Vector.<IDataInterpreter>, isIncoming:Boolean):void{
			var parts:Array = propName.split(".");
			var value:* = data;
			for each(var prop:String in parts){
				if(!value.hasOwnProperty(prop)){
					value = null;
					return; // don't over-write default values if no data came through (as opposed to a null value coming through)
				}
				value = value[prop];
			}
			if(interpreters){
				for each(var dataInterpeter:IDataInterpreter in interpreters){
					if(isIncoming)value = dataInterpeter.incoming(value);
					else value = dataInterpeter.outgoing(value);
				}
			}
			parts = mappedTo.split(".");
			for(var i:int=0; i<parts.length-1; ++i){
				var newIntoObj:Object = intoObj[parts[i]];
				if(!newIntoObj){
					newIntoObj = {};
					intoObj[parts[i]] = newIntoObj;
				}
				intoObj = newIntoObj;
			}
			// special case for booleans
			var currValue:* = intoObj[parts[parts.length-1]];
			if(currValue!=null && (currValue is Boolean)){
				intoObj[parts[parts.length-1]] = booleanInterpreter(value);
			}else{
				intoObj[parts[parts.length-1]] = value;
			}
		}
		public function booleanInterpreter(value:*):Boolean{
			return (value==true || value=="true" || value=="yes" || value==1);
		}
		
		/**
		 * 
		 * @param propName the name of the property on the data being interpretted.
		 * @param mappedTo the name of the property on the destination object being filled.
		 * @param interpreter should be a Vector.<IDataInterpreter> or Array of IDataInterpreters
		 * 
		 */
		public function addPropMapping(propName:String, mappedTo:String, interpreters:*=null):void{
			
			if(!_propMapping){
				_propMapping = new Dictionary();
				_propLookup = new Dictionary();
			}else if(_propLookup[propName]){
				throw new Error("Property "+propName+" already mapped");
			}
			_propMapping[mappedTo] = propName;
			_propLookup[propName] = mappedTo;
			
			if(interpreters is IDataInterpreter){
				interpreters = Vector.<IDataInterpreter>([interpreters]);
			}else if(interpreters is Array){
				interpreters = Vector.<IDataInterpreter>(interpreters);
			}
			var castInter:Vector.<IDataInterpreter> = (interpreters as Vector.<IDataInterpreter>);
			if(castInter){
				if(!_interpreters)_interpreters = new Dictionary();
				_interpreters[mappedTo] = castInter;
			}
		}
		public function removePropMapping(propName:String):void{
			if(!_propMapping || !_propLookup[propName]){
				throw new Error("Property "+propName+" not mapped");
			}
			
			var mappedTo:String = _propLookup[propName];
			
			delete _propMapping[mappedTo];
			delete _interpreters[mappedTo];
			delete _propLookup[propName];
			
		}
	}
}