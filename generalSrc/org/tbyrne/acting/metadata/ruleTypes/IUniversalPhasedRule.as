package org.tbyrne.acting.metadata.ruleTypes
{
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;
	
	public interface IUniversalPhasedRule extends IUniversalRule
	{
		function get phases():Array;
	}
}