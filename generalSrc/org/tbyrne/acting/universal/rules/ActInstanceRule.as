package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	
	public class ActInstanceRule extends PhasedActRule
	{
		public function get act():IUniversalAct{
			return _act;
		}
		public function set act(value:IUniversalAct):void{
			_act = value;
		}
		
		private var _act:IUniversalAct;
		
		public function ActInstanceRule(act:IUniversalAct=null, beforePhases:Array=null, afterPhases:Array=null){
			super(beforePhases, afterPhases);
			_act = act;
		}
		override public function shouldReact(act:IUniversalAct):Boolean{
			return _act==act;
		}
	}
}