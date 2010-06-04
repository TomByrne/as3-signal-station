package org.farmcode.acting.universal.ruleTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;

	public interface IUniversalRule
	{
		function shouldExecute(act:IUniversalAct):Boolean;
		function shouldExecuteBefore(act:IUniversalAct, beforeInstigator:Boolean, afterInstigator:Boolean):Boolean;
	}
}