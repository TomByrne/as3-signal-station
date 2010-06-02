package org.farmcode.acting.universal.ruleTypes
{
	import org.farmcode.acting.actTypes.IUniversalAct;
	import org.farmcode.acting.universal.reactions.IActReaction;

	public interface IUniversalRule
	{
		function shouldReact(act:IUniversalAct):Boolean;
		function shouldReactBefore(act:IUniversalAct, reaction:IActReaction):Boolean;
		function shouldReactAfter(act:IUniversalAct, reaction:IActReaction):Boolean;
	}
}