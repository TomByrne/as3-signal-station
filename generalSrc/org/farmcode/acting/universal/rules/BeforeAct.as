package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.rules.abstract.BaseActInstanceRule;
	
	public class BeforeAct extends BaseActInstanceRule
	{
		public function BeforeAct(act:IUniversalAct=null)
		{
			super(true, act);
		}
	}
}