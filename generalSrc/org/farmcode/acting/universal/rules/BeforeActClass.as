package org.farmcode.acting.universal.rules
{
	import org.farmcode.acting.universal.rules.abstract.BaseActClassRule;

	public class BeforeActClass extends BaseActClassRule
	{
		public function BeforeActClass(actClass:Class=null)
		{
			super(true, actClass);
		}
	}
}