package org.tbyrne.acting.metadata.ruleTypes
{
	import org.tbyrne.acting.universal.ruleTypes.IUniversalRule;

	public interface IUniversalClassRule extends IUniversalRule
	{
		function set actClass(value:Class):void;
	}
}