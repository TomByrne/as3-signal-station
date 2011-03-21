package org.tbyrne.acting.universal.rules
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.actTypes.IUniversalTypeAct;
	import org.tbyrne.acting.metadata.ruleTypes.IUniversalPhasedRule;

	public class ActTypeRule extends ActClassRule implements IUniversalPhasedRule
	{
		public function get phases():Array{
			if(actType && !(beforePhases && beforePhases.length) && !(afterPhases && afterPhases.length)){
				return [actType];
			}else{
				return null;
			}
		}
		
		
		public var actType:String;
		
		
		public function ActTypeRule(actClass:Class=null, beforePhases:Array=null, afterPhases:Array=null){
			super(actClass, beforePhases, afterPhases);
		}
		override public function shouldReact(act:IUniversalAct):Boolean{
			if(actType && super.shouldReact(act)){
				var cast:IUniversalTypeAct = (act as IUniversalTypeAct);
				return (cast && cast.actType==actType);
			}
			return false;
		}
	}
}