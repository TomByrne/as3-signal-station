package org.tbyrne.actLibrary.application.states.reactors
{
	import flash.utils.Dictionary;
	
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.actLibrary.core.IRevertableAct;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.actLibrary.application.states.serialisers.IPropSerialiser;
	
	public class PerformActReactor implements IAppStateReactor
	{
		
		public function get act():IAct{
			return _act;
		}
		public function set act(value:IAct):void{
			if(_act!=value){
				_act = value;
				_revertableAct = (value as IRevertableAct);
			}
		}
		
		public function get actProps():Dictionary{
			return _actProps;
		}
		public function set actProps(value:Dictionary):void{
			if(_actProps!=value){
				_actProps = value;
				lastPropValues = new Dictionary();
			}
		}
		
		
		/*public function get serialisers():Object{
			return _serialisers;
		}
		public function set serialisers(value:Object):void{
			if(_serialisers!=value){
				_serialisers = value;
			}
		}
		
		private var _serialisers:Object;*/
		
		private var _actProps:Dictionary;
		private var _act:IAct;
		private var _revertableAct:IRevertableAct;
		private var lastPropValues:Dictionary;
		
		public function PerformActReactor(act:IAct=null, actProps:Dictionary=null){
			this.act = act;
			this.actProps = actProps;
		}
		public function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			if(_actProps){
				//var serialiser:IPropSerialiser;
				for(var destProp:String in _actProps){
					var sourceProp:String = _actProps[destProp];
					/*if(_serialisers){
						serialiser = _serialisers[sourceProp];
					}*/
					var value:* = newMatch.parameters[sourceProp];
					lastPropValues[sourceProp] = value;
					//if(serialiser)value = serialiser.deserialise(value);
					_act[destProp] = value;
				}
			}
			return _act;
		}
		
		public function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			if(_revertableAct && _revertableAct.doRevert){
				return _revertableAct.revertAct;
			}
			return null;
		}
		
		public function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			if(_actProps){
				var doReturn:Boolean;
				//var serialiser:IPropSerialiser;
				for(var destProp:String in _actProps){
					var sourceProp:String = _actProps[destProp];
					var newValue:* = newMatch.parameters[sourceProp];
					if(newValue!=lastPropValues[sourceProp]){
						lastPropValues[sourceProp] = newValue;
						/*if(_serialisers){
							serialiser = _serialisers[sourceProp];
							if(serialiser)newValue = serialiser.deserialise(newValue);
						}*/
						_act[destProp] = newValue;
						doReturn = true;
					}
				}
				if(doReturn){
					return _act;
				}
			}
			return null;
		}
	}
}