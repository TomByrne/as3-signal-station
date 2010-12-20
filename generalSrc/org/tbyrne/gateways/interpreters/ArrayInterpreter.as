package org.tbyrne.gateways.interpreters
{
	public class ArrayInterpreter implements IDataInterpreter
	{
		public var vectorType:*;
		public var nestedInterpreters:Vector.<IDataInterpreter>;
		
		public function ArrayInterpreter(nestedInterpreters:*=null, vectorType:*=null){
			this.vectorType = vectorType;
			
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
						for each(var datInt:IDataInterpreter in nestedInterpreters){
							item = datInt.incoming(item);
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
			return data;
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
						for each(var datInt:IDataInterpreter in nestedInterpreters){
							item = datInt.outgoing(item);
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