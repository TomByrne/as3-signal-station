package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.rules.abstract.BaseActInstanceRule;

	public class AfterAct extends BaseActInstanceRule
	{
		public function AfterAct(act:IUniversalAct=null)
		{
			super(false, act);
		}
	}
}