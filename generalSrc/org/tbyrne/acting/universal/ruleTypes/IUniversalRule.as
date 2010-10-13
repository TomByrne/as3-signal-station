package org.tbyrne.acting.universal.ruleTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.reactions.IActReaction;

	public interface IUniversalRule
	{
		function shouldReact(act:IUniversalAct):Boolean;
		function shouldReactBefore(act:IUniversalAct, reaction:IActReaction):Boolean;
		function shouldReactAfter(act:IUniversalAct, reaction:IActReaction):Boolean;
	}
}