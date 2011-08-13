package org.tbyrne.display.validation
{
	import flash.utils.Dictionary;

	public class FlagChainer
	{
		private static var _bundles:Dictionary = new Dictionary(true);
		
		public static function chainFlag(flag:ValidationFlag, toFlags:Array, extraReadyChecker:Function=null):void{
			unchainFlag(flag);
			
			var toFlag:ValidationFlag;
			var readyChecker:Function = function(from:ValidationFlag):Boolean{
				for each(toFlag in toFlags){
					if(!toFlag.valid){
						return false;
					}
				}
				if(extraReadyChecker!=null && !extraReadyChecker.call(null,from)){
					return false;
				}
				return true;
			}
				
				
				
			var onValidate:Function = function(from:ValidationFlag, chained:ValidationFlag):void{
				chained.validate();
			}
			for each(toFlag in toFlags){
				toFlag.validateAct.addHandler(onValidate,[flag]);
			}
			
			flag.readyChecker = readyChecker;
			
			_bundles[flag] = new ChainedBundle(toFlags, onValidate, readyChecker);
		}
		
		public static function unchainFlag(flag:ValidationFlag):void{
			var bundle:ChainedBundle = _bundles[flag];
			
			if(bundle){
				if(flag.readyChecker==bundle.readyChecker){
					flag.readyChecker = null;
				}
				for each(var toFlag:ValidationFlag in bundle.toFlags){
					toFlag.validateAct.removeHandler(bundle.onValidateHook);
				}
				delete _bundles[flag];
			}
		}
	}
}
class ChainedBundle{
	public function ChainedBundle(toFlags:Array, onValidateHook:Function, readyChecker:Function){
		this.toFlags = toFlags;
		this.onValidateHook = onValidateHook;
		this.readyChecker = readyChecker;
	}
	
	public var toFlags:Array;
	
	public var onValidateHook:Function;
	
	public var readyChecker:Function;
}