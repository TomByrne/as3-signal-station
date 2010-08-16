package org.farmcode.data.expressions
{
	import org.farmcode.data.dataTypes.IValueProvider;
	
	public class ParameterisedExpression extends NumberExpression{
		
		public function get func():Function{
			return _func;
		}
		public function set func(value:Function):void{
			if(_func!=value){
				_func = value;
				reevaluate();
			}
		}
		public function get paramCount():int{
			return _paramCount;
		}
		public function set paramCount(value:int):void{
			if(_paramCount!=value){
				_paramCount = value;
				reevaluate();
			}
		}
		
		protected var _func:Function;
		protected var _paramCount:int;
		protected var _paramProviders:Array;
		
		public function ParameterisedExpression(func:Function=null, paramCount:int=0, paramProviders:Array=null){
			super();
			_paramProviders = (paramProviders || []);
			this.paramCount = paramCount;
			this.func = func;
		}
		public function setParamProvider(paramProvider:*, index:int):void{
			if(paramProvider){
				stopListening(_paramProviders[index]);
				_paramProviders[index] = paramProvider;
				listenTo(paramProvider as IValueProvider);
				reevaluate();
			}else{
				clearParamProvider(index);
			}
		}
		public function getParamProvider(index:int):IValueProvider{
			return _paramProviders[index];
		}
		public function clearParamProvider(index:int):void{
			stopListening(_paramProviders[index]);
			_paramProviders[index] = null;
			reevaluate();
		}
		override protected function reevaluate():void{
			if(func!=null){
				var allFound:Boolean = true;
				var params:Array = [];
				if(_paramCount<=_paramProviders.length){
					for(var i:int=0; i<_paramProviders.length; i++){
						var value:* = _paramProviders[i];
						var paramProvider:IValueProvider = (value as IValueProvider);
						if(!paramProvider){
							if(!value){
								allFound = false;
								break;
							}else{
								params[i] = value;
							}
						}else{
							listenTo(paramProvider);
							params[i] = paramProvider.value;
						}
					}
				}else{
					allFound = false;
				}
				if(allFound){
					var result:* = func.apply(null,params);
					setResult(result);
				}else{
					paramsNotSet();
				}
			}else{
				setResult(null);
			}
		}
		protected function paramsNotSet():void{
			setResult(null);
		}
	}
}