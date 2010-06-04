package au.com.thefarmdigital.utils
{
	import org.farmcode.reflection.ReflectionUtils;
	
	public function methodResolver(subject:Object, methodName:String):Function{
		return function(... rest):*{
			var func: Function = null;
			if (subject == null) {
				func = ReflectionUtils.getFunctionByName(methodName);
			} else {
				func = subject[methodName];
			}
			return func.apply(null,rest);
		}
	}
}