package org.farmcode.acting.universal.reactions
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.display.core.IView;

	public interface IActReaction extends IView
	{
		/**
		 * an array of increasingly general phase names.<br>
		 * e.g. <code>["sitesStream.resolve","application.dataLoad","net.load"]</code>
		 */
		function get phases():Array;
		
		function get universalRules():Array;
		/**
		 * handler(universalAct:IActReaction, universalRule:IUniversalRule)
		 */
		function get universalRuleAddedAct():IAct;
		/**
		 * handler(universalAct:IActReaction, universalRule:IUniversalRule)
		 */
		function get universalRuleRemovedAct():IAct;
		
		function execute(executor:UniversalActExecution, params:Array):void;
	}
}