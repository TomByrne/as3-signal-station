package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.universal.rules.abstract.BaseActClassRule;

	public class AfterActClass extends BaseActClassRule
	{
		public function AfterActClass(actClass:Class=null)
		{
			super(false, actClass);
		}
	}
}