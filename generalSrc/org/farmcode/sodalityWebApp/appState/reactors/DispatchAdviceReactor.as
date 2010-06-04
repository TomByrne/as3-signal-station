package org.farmcode.sodalityWebApp.appState.reactors
{
	import flash.utils.Dictionary;
	
	import org.farmcode.sodality.advice.IAdvice;
	import org.farmcode.sodalityLibrary.core.adviceTypes.IRevertableAdvice;
	import org.farmcode.sodalityWebApp.appState.AppStateMatch;
	
	public class DispatchAdviceReactor implements IAppStateReactor
	{
		
		public function get advice():IAdvice{
			return _advice;
		}
		public function set advice(value:IAdvice):void{
			if(_advice!=value){
				_advice = value;
				_revertableAdvice = (value as IRevertableAdvice);
			}
		}
		
		public function get adviceProps():Dictionary{
			return _adviceProps;
		}
		public function set adviceProps(value:Dictionary):void{
			if(_adviceProps!=value){
				_adviceProps = value;
				lastPropValues = new Dictionary();
			}
		}
		
		private var _adviceProps:Dictionary;
		private var _advice:IAdvice;
		private var _revertableAdvice:IRevertableAdvice;
		private var lastPropValues:Dictionary;
		
		public function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice{
			if(_adviceProps){
				for(var destProp:String in _adviceProps){
					var sourceProp:String = _adviceProps[destProp];
					_advice[destProp] = lastPropValues[sourceProp] = newMatch.parameters[sourceProp];
				}
			}
			return _advice;
		}
		
		public function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice{
			if(_revertableAdvice){
				return _revertableAdvice.revertAdvice;
			}
			return null;
		}
		
		public function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAdvice{
			if(_adviceProps){
				var doReturn:Boolean;
				for(var destProp:String in _adviceProps){
					var sourceProp:String = _adviceProps[destProp];
					var newValue:* = newMatch.parameters[sourceProp];
					if(newValue!=lastPropValues[sourceProp]){
						_advice[destProp] = lastPropValues[sourceProp] = newValue;
						doReturn = true;
					}
				}
				if(doReturn){
					return _advice;
				}
			}
			return null;
		}
	}
}