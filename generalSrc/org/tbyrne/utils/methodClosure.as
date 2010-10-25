package org.tbyrne.utils
{
	public function methodClosure(func:Function, ... additionalArgs):Function{
		return function(... params):*{
			var args:Array;
			if(params.length){
				if(additionalArgs.length){
					args = params.concat(additionalArgs);
				}else{
					args = params;
				}
			}else{
				args = additionalArgs;
			}
			return func.apply(null, args);
		}
	}
}