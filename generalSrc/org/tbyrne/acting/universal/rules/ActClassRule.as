package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalClassRule;
	
	public class ActClassRule extends PhasedActRule implements IUniversalClassRule
	{
		
		public function get actClass():Class{
			return _actClass;
		}
		public function set actClass(value:Class):void{
			_actClass = value;
		}
		
		private var _actClass:Class;
		
		public function ActClassRule(actClass:Class=null, beforePhases:Array=null, afterPhases:Array=null){
			super(beforePhases, afterPhases);
			_actClass = actClass;
		}
		override public function shouldReact(act:IUniversalAct):Boolean{
			return act is _actClass;
		}
	}
}