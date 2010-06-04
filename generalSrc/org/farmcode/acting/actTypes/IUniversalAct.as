package org.farmcode.acting.actTypes
{
	import flash.display.DisplayObject;
	
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.acting.universal.ruleTypes.IUniversalRule;
	
	public interface IUniversalAct extends IAct
	{
		function universalPerform(execution:UniversalActExecution, ... params):void;
		
		/**
		 * handler(act:IUniversalAct)
		 */
		function get scopeDisplayChangeAct():IAct;
		function get scopeDisplay():DisplayObject;
		
		function get universalRules():Array;
		/**
		 * handler(universalAct:IUniversalAct, universalRule:IUniversalRule)
		 */
		function get universalRuleAddedAct():IAct;
		/**
		 * handler(universalAct:IUniversalAct, universalRule:IUniversalRule)
		 */
		function get universalRuleRemovedAct():IAct;
	}
}