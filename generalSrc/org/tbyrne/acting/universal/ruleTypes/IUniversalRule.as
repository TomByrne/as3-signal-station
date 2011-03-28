package org.tbyrne.acting.universal.ruleTypes
{
	import org.tbyrne.acting.actTypes.IUniversalAct;
	import org.tbyrne.acting.universal.reactions.IActReaction;

	public interface IUniversalRule
	{
		function shouldReact(act:IUniversalAct):Boolean;
		/**
		 * 
		 * @return -1 if this IAct should be performed before the IAct provided.
		 * 0 if it is unclear which should be performed first. 1 if this IAct should be
		 * performed after the IAct provided.
		 * 
		 */
		function sortAgainst(act:IUniversalAct, reaction:IActReaction):int;
	}
}