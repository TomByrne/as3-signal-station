package org.farmcode.acting.metadata.ruleTypes
{
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;

	public interface IUniversalClassRule extends IUniversalRule
	{
		function set actClass(value:Class):void;
	}
}