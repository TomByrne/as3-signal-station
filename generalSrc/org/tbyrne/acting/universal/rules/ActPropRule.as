package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;

	public class ActPropRule extends ActClassRule
	{
		public function get props():Object{
			return _props;
		}
		public function set props(value:Object):void{
			_props = value;
		}
		
		private var _props:Object;
		
		
		public function ActPropRule(actClass:Class=null, beforePhases:Array=null, afterPhases:Array=null){
			super(actClass, beforePhases, afterPhases);
		}
		override public function shouldReact(act:IUniversalAct):Boolean{
			if(_props && super.shouldReact(act)){
				var propsMatch:Boolean = true;
				for(var i:String in _props){
					if(act[i]!=_props[i]){
						propsMatch = false;
						break;
					}
				}
				return propsMatch;
			}
			return false;
		}
	}
}