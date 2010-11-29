package org.tbyrne.gateways.interpreters
{
	public class ArrayInterpreter implements IDataInterpreter
	{
		public var vectorType:*;
		public var nestedInterpreter:IDataInterpreter;
		
		public function ArrayInterpreter(nestedInterpreter:IDataInterpreter=null, vectorType:*=null){
			this.vectorType = vectorType;
			this.nestedInterpreter = nestedInterpreter;
		}
		
		public function incoming(data:*):*{
			var cast:Array = (data as Array);
			if(cast){
				var ret:*;
				if(vectorType!=null){
					ret = new vectorType();
				}else{
					ret = [];
				}
				for each(var item:* in cast){
					if(item!=null){
						if(nestedInterpreter){
							item = nestedInterpreter.incoming(item);
						}
						ret.push(item);
					}
				}
				if(vectorType!=null){
					return vectorType(ret);
				}else{
					return ret;
				}
			}
			return cast;
		}
		
		public function outgoing(data:*):*{
			var cast:*;
			if(vectorType!=null){
				cast = (data as vectorType);
			}else{
				cast = (data as Array);
			}
			if(cast){
				var ret:Array = [];
				for each(var item:* in data){
					if(item!=null){
						if(nestedInterpreter){
							item = nestedInterpreter.outgoing(item);
						}
						ret.push(item);
					}
				}
				return ret;
			}else{
				return data;
			}
		}
	}
}