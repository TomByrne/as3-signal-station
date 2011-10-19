package org.tbyrne.composeSodality
{
	import org.tbyrne.actLibrary.application.states.AppStateMatch;
	import org.tbyrne.actLibrary.application.states.reactors.IAppStateReactor;
	import org.tbyrne.actLibrary.core.SimpleDataAct;
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.display.DisplayNamespace;

	public class AddTraitsReactor implements IAppStateReactor
	{
		
		public function get traits():Array{
			return _traits;
		}
		public function set traits(value:Array):void{
			if(_traits!=value){
				_traits = value;
				_addTraits.actData = _traits;
				_removeTraits.actData = _traits;
			}
		}
		
		private var _traits:Array;
		
		
		public var _addTraits:SimpleDataAct;
		public var _removeTraits:SimpleDataAct;
		
		public function AddTraitsReactor(){
			_addTraits = new SimpleDataAct(ComposeActTypes.ADD_TRAITS);
			_removeTraits = new SimpleDataAct(ComposeActTypes.REMOVE_TRAITS);
		}
		public function enable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			return _addTraits;
		}
		public function disable(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			return _removeTraits;
		}
		public function refresh(newMatch:AppStateMatch, oldMatch:AppStateMatch):IAct{
			return null;
		}
	}
}